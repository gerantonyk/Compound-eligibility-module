// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { Script, console2 } from "forge-std/Script.sol";
import { DisjunctionEligibility } from "src/DisjunctionEligibilityModule.sol";
import { HatsModuleFactory, deployModuleInstance } from "hats-module/utils/DeployFunctions.sol";

// Deploy the implementation contract for DisjunctionEligibility
contract DeployImplementation is Script {
    DisjunctionEligibility public implementation;
    bytes32 public SALT = bytes32(abi.encode(0x4a75)); // ~ H(4) A(a) T(7) S(5)

    string public version = "0.1.0"; // increment with each deploy
    bool private verbose = true;

    function prepare(string memory _version, bool _verbose) public {
        version = _version;
        verbose = _verbose;
    }

    function run() public {
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(privKey);
        vm.startBroadcast(deployer);

        // deploy the implementation
        implementation = new DisjunctionEligibility{ salt: SALT}(version);

        vm.stopBroadcast();

        if (verbose) {
            console2.log("Implementation:", address(implementation));
        }
    }
}
