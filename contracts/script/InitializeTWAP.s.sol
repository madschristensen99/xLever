// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {Vault} from "../src/xLever/Vault.sol";
import {TWAPOracle} from "../src/xLever/modules/TWAPOracle.sol";

contract InitializeTWAP is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Deployed vault addresses
        address spyVault = 0xE5Fb4246fe7513643c1e5427737efCdc5555657E;
        address qqqVault = 0xA79826D1A4374714ff35B7BF9450D2Bb60e5BC67;
        
        // Starting prices (in 6 decimals, representing USDC value)
        // SPY ~$580, QQQ ~$500
        uint128 spyStartPrice = 580e6;
        uint128 qqqStartPrice = 500e6;
        
        console.log("=== Initializing TWAP for Vaults ===");
        console.log("SPY Vault:", spyVault);
        console.log("QQQ Vault:", qqqVault);
        console.log("SPY Start Price:", spyStartPrice);
        console.log("QQQ Start Price:", qqqStartPrice);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Get vault contracts
        Vault spyVaultContract = Vault(spyVault);
        Vault qqqVaultContract = Vault(qqqVault);
        
        // Initialize TWAP buffers through vault admin function
        console.log("\nInitializing SPY TWAP...");
        spyVaultContract.initializeOracle(spyStartPrice);
        
        console.log("Initializing QQQ TWAP...");
        qqqVaultContract.initializeOracle(qqqStartPrice);
        
        vm.stopBroadcast();
        
        console.log("\n=== TWAP Initialization Complete ===");
        
        // Verify TWAP values
        (uint128 spyTWAP,) = spyVaultContract.getCurrentTWAP();
        (uint128 qqqTWAP,) = qqqVaultContract.getCurrentTWAP();
        
        console.log("\nVerified TWAP Values:");
        console.log("SPY TWAP:", spyTWAP);
        console.log("QQQ TWAP:", qqqTWAP);
    }
}
