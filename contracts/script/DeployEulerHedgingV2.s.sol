// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {EulerHedgingModuleV2} from "../src/xLever/modules/EulerHedgingModuleV2.sol";

contract DeployEulerHedgingV2 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Euler V2 vault addresses
        address evc = 0x0C9a3dd6b8F28529d72d7f9cE918D493519EE383;
        address usdcVault = 0x014ba821525Be6eDd25F3eE7C6A37274382c8047;
        address spyVault = 0xe39b100a33f7C861088A9C16642534dd29cDf83d;
        address qqqVault = 0xfC78951DcffdD8bDa662Aa7D9c697bE55d53712A;
        
        // Token addresses
        address usdc = 0x6b57475467cd854d36Be7FB614caDa5207838943;
        address wSPYx = 0x9eF9f9B22d3CA9769e28e769e2AAA3C2B0072D0e;
        address wQQQx = 0x267ED9BC43B16D832cB9Aaf0e3445f0cC9f536d9;
        
        console.log("=== Deploying EulerHedgingModuleV2 (USDC-based) ===");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SPY hedging module V2
        EulerHedgingModuleV2 spyHedgingV2 = new EulerHedgingModuleV2(
            evc,
            usdcVault,
            spyVault,
            usdc,
            wSPYx
        );
        console.log("SPY Hedging Module V2:", address(spyHedgingV2));
        
        // Deploy QQQ hedging module V2
        EulerHedgingModuleV2 qqqHedgingV2 = new EulerHedgingModuleV2(
            evc,
            usdcVault,
            qqqVault,
            usdc,
            wQQQx
        );
        console.log("QQQ Hedging Module V2:", address(qqqHedgingV2));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Complete ===");
        console.log("Update frontend with these addresses:");
        console.log("SPY_HEDGING_MODULE:", address(spyHedgingV2));
        console.log("QQQ_HEDGING_MODULE:", address(qqqHedgingV2));
    }
}
