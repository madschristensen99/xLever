// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {IEVault} from "../src/EVault/IEVault.sol";

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
}

contract SupplyEulerLiquidity is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Euler V2 vault addresses
        address usdcVault = 0x014ba821525Be6eDd25F3eE7C6A37274382c8047;
        address spyVault = 0xe39b100a33f7C861088A9C16642534dd29cDf83d;
        address qqqVault = 0xfC78951DcffdD8bDa662Aa7D9c697bE55d53712A;
        
        // Token addresses
        address usdc = 0x6b57475467cd854d36Be7FB614caDa5207838943;
        address wSPYx = 0x9eF9f9B22d3CA9769e28e769e2AAA3C2B0072D0e;
        address wQQQx = 0x267ED9BC43B16D832cB9Aaf0e3445f0cC9f536d9;
        
        console.log("=== Supplying Liquidity to Euler Vaults ===");
        console.log("Deployer:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Supply USDC to USDC vault
        uint256 usdcBalance = IERC20(usdc).balanceOf(deployer);
        console.log("USDC Balance:", usdcBalance);
        
        if (usdcBalance > 0) {
            uint256 supplyAmount = usdcBalance / 2; // Supply half
            console.log("Supplying", supplyAmount, "USDC to Euler vault");
            IERC20(usdc).approve(usdcVault, supplyAmount);
            IEVault(usdcVault).deposit(supplyAmount, deployer);
            console.log("SUCCESS: USDC supplied");
        }
        
        // Supply wSPYx to SPY vault (if you have any)
        uint256 spyBalance = IERC20(wSPYx).balanceOf(deployer);
        console.log("wSPYx Balance:", spyBalance);
        
        if (spyBalance > 0) {
            console.log("Supplying", spyBalance, "wSPYx to Euler vault");
            IERC20(wSPYx).approve(spyVault, spyBalance);
            IEVault(spyVault).deposit(spyBalance, deployer);
            console.log("SUCCESS: wSPYx supplied");
        }
        
        // Supply wQQQx to QQQ vault (if you have any)
        uint256 qqqBalance = IERC20(wQQQx).balanceOf(deployer);
        console.log("wQQQx Balance:", qqqBalance);
        
        if (qqqBalance > 0) {
            console.log("Supplying", qqqBalance, "wQQQx to Euler vault");
            IERC20(wQQQx).approve(qqqVault, qqqBalance);
            IEVault(qqqVault).deposit(qqqBalance, deployer);
            console.log("SUCCESS: wQQQx supplied");
        }
        
        vm.stopBroadcast();
        
        console.log("\n=== Liquidity Supply Complete ===");
    }
}
