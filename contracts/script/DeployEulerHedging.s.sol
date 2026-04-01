// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {EulerHedgingModule} from "../src/xLever/modules/EulerHedgingModule.sol";

contract DeployEulerHedging is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Euler V2 vault addresses (from FinalSetup.s.sol)
        address evc = 0x0C9a3dd6b8F28529d72d7f9cE918D493519EE383;
        address usdcVault = 0x014ba821525Be6eDd25F3eE7C6A37274382c8047;
        address spyVault = 0xe39b100a33f7C861088A9C16642534dd29cDf83d;
        address qqqVault = 0xfC78951DcffdD8bDa662Aa7D9c697bE55d53712A;
        
        // Token addresses
        address usdc = 0x6b57475467cd854d36Be7FB614caDa5207838943;
        address wSPYx = 0x9eF9f9B22d3CA9769e28e769e2AAA3C2B0072D0e;
        address wQQQx = 0x267ED9BC43B16D832cB9Aaf0e3445f0cC9f536d9;
        
        console.log("=== Deploying EulerHedgingModule Contracts ===");
        console.log("EVC:", evc);
        console.log("USDC Vault:", usdcVault);
        console.log("SPY Vault:", spyVault);
        console.log("QQQ Vault:", qqqVault);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SPY hedging module
        EulerHedgingModule spyHedging = new EulerHedgingModule(
            evc,
            usdcVault,
            spyVault,
            usdc,
            wSPYx
        );
        console.log("\nSPY Hedging Module:", address(spyHedging));
        
        // Deploy QQQ hedging module
        EulerHedgingModule qqqHedging = new EulerHedgingModule(
            evc,
            usdcVault,
            qqqVault,
            usdc,
            wQQQx
        );
        console.log("QQQ Hedging Module:", address(qqqHedging));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Complete ===");
        console.log("\nAdd these addresses to your frontend:");
        console.log("SPY_HEDGING_MODULE:", address(spyHedging));
        console.log("QQQ_HEDGING_MODULE:", address(qqqHedging));
    }
}
