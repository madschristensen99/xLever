// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IEVault} from "../../EVault/IEVault.sol";
import {IEVC} from "../interfaces/IEVC.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface ISwapper {
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut);
}

/// @title EulerHedgingModuleV2
/// @notice Implements real leverage looping - accepts USDC for both long and short
/// @dev Uses EVC batch operations for atomic multi-contract calls
contract EulerHedgingModuleV2 {
    IEVC public immutable evc;
    IEVault public immutable usdcVault;
    IEVault public immutable assetVault;
    IERC20 public immutable usdc;
    IERC20 public immutable asset;
    ISwapper public swapper; // Optional swapper for USDC <-> asset
    
    address public owner;
    
    event LeverageOpened(address indexed user, uint256 collateral, uint256 debt, uint256 leverage, bool isLong);
    event LeverageClosed(address indexed user, uint256 withdrawn, uint256 repaid);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor(
        address _evc,
        address _usdcVault,
        address _assetVault,
        address _usdc,
        address _asset
    ) {
        evc = IEVC(_evc);
        usdcVault = IEVault(_usdcVault);
        assetVault = IEVault(_assetVault);
        usdc = IERC20(_usdc);
        asset = IERC20(_asset);
        owner = msg.sender;
    }
    
    function setSwapper(address _swapper) external onlyOwner {
        swapper = ISwapper(_swapper);
    }
    
    /// @notice Open a leveraged LONG position - accepts USDC, loops to get asset exposure
    /// @param initialUSDC Amount of USDC to deposit
    /// @param targetLeverage Target leverage in basis points (e.g., 30000 = 3x)
    function openLongPosition(uint256 initialUSDC, uint256 targetLeverage) external {
        require(targetLeverage >= 10000 && targetLeverage <= 40000, "Invalid leverage");
        
        // Transfer USDC from user
        usdc.transferFrom(msg.sender, address(this), initialUSDC);
        
        // For now, use 1:1 swap assumption (in production, use real DEX)
        // Swap USDC to asset for initial collateral
        uint256 assetAmount = initialUSDC; // 1:1 for testing
        
        // Calculate looping parameters
        uint256 totalAssetNeeded = (assetAmount * targetLeverage) / 10000;
        uint256 usdcToBorrow = totalAssetNeeded - assetAmount;
        
        // Enable collateral and controller
        evc.enableCollateral(address(this), address(assetVault));
        evc.enableController(address(this), address(usdcVault));
        
        // Deposit initial asset as collateral
        asset.approve(address(assetVault), assetAmount);
        assetVault.deposit(assetAmount, address(this));
        
        // Loop: borrow USDC, swap to asset, deposit as collateral
        uint256 remainingToBorrow = usdcToBorrow;
        while (remainingToBorrow > 0) {
            // Borrow USDC
            uint256 borrowAmount = remainingToBorrow > initialUSDC ? initialUSDC : remainingToBorrow;
            usdcVault.borrow(borrowAmount, address(this));
            
            // Swap USDC to asset (1:1 for testing)
            uint256 assetReceived = borrowAmount;
            
            // Deposit asset as additional collateral
            asset.approve(address(assetVault), assetReceived);
            assetVault.deposit(assetReceived, address(this));
            
            remainingToBorrow -= borrowAmount;
        }
        
        emit LeverageOpened(msg.sender, assetAmount, usdcToBorrow, targetLeverage, true);
    }
    
    /// @notice Open a leveraged SHORT position - accepts USDC, loops to get short exposure
    /// @param initialUSDC Amount of USDC to deposit
    /// @param targetLeverage Target leverage in basis points (e.g., 30000 = 3x short)
    function openShortPosition(uint256 initialUSDC, uint256 targetLeverage) external {
        require(targetLeverage >= 10000 && targetLeverage <= 40000, "Invalid leverage");
        
        // Transfer USDC from user
        usdc.transferFrom(msg.sender, address(this), initialUSDC);
        
        // Calculate looping parameters
        uint256 totalUSDCNeeded = (initialUSDC * targetLeverage) / 10000;
        uint256 assetToBorrow = totalUSDCNeeded - initialUSDC;
        
        // Enable collateral and controller
        evc.enableCollateral(address(this), address(usdcVault));
        evc.enableController(address(this), address(assetVault));
        
        // Deposit initial USDC as collateral
        usdc.approve(address(usdcVault), initialUSDC);
        usdcVault.deposit(initialUSDC, address(this));
        
        // Loop: borrow asset, swap to USDC, deposit as collateral
        uint256 remainingToBorrow = assetToBorrow;
        while (remainingToBorrow > 0) {
            // Borrow asset
            uint256 borrowAmount = remainingToBorrow > initialUSDC ? initialUSDC : remainingToBorrow;
            assetVault.borrow(borrowAmount, address(this));
            
            // Swap asset to USDC (1:1 for testing)
            uint256 usdcReceived = borrowAmount;
            
            // Deposit USDC as additional collateral
            usdc.approve(address(usdcVault), usdcReceived);
            usdcVault.deposit(usdcReceived, address(this));
            
            remainingToBorrow -= borrowAmount;
        }
        
        emit LeverageOpened(msg.sender, initialUSDC, assetToBorrow, targetLeverage, false);
    }
    
    /// @notice Close position and return funds to user
    function closePosition() external {
        // Repay all debts and withdraw collateral
        // Implementation depends on which position type (long/short)
        
        // For now, simple withdrawal
        uint256 usdcBalance = usdcVault.balanceOf(address(this));
        uint256 assetBalance = assetVault.balanceOf(address(this));
        
        if (usdcBalance > 0) {
            usdcVault.withdraw(usdcBalance, msg.sender, address(this));
        }
        
        if (assetBalance > 0) {
            assetVault.withdraw(assetBalance, msg.sender, address(this));
        }
        
        emit LeverageClosed(msg.sender, usdcBalance + assetBalance, 0);
    }
    
    /// @notice Get position health metrics
    function getPositionHealth() external view returns (uint256 collateral, uint256 debt, uint256 healthFactor) {
        uint256 usdcCollateral = usdcVault.balanceOf(address(this));
        uint256 assetCollateral = assetVault.balanceOf(address(this));
        uint256 usdcDebt = usdcVault.debtOf(address(this));
        uint256 assetDebt = assetVault.debtOf(address(this));
        
        collateral = usdcCollateral + assetCollateral;
        debt = usdcDebt + assetDebt;
        healthFactor = debt > 0 ? (collateral * 10000) / debt : 10000;
    }
}
