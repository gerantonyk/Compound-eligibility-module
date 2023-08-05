// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { Test, console2 } from "forge-std/Test.sol";
import { CompoundEligibility } from "src/CompoundEligibilityModule.sol";

import { DeployImplementation } from "script/CompoundEligibilityModule.s.sol";
import {
    HatsModuleFactory, IHats, deployModuleInstance, deployModuleFactory
} from "hats-module/utils/DeployFunctions.sol";
import { MockElegibilityModule } from "src/mocks/MockElegibilityModule.sol";

contract CompoundEligibilityTest is Test, DeployImplementation {
    HatsModuleFactory public factory;
    CompoundEligibility public instance;
    bytes public otherImmutableArgs;
    bytes public initData;

    uint256 public tophat;
    uint256 public compoundHat;
    address public eligibility = makeAddr("eligibility");
    address public dao = makeAddr("dao");

    address public eligibleInModule1 = makeAddr("eligibleInModule1");
    address public eligibleInModule2 = makeAddr("eligibleInModule2");
    address public eligibleInModule1and2 = makeAddr("eligibleInModule1and2");
    address public ineligible = makeAddr("ineligible");

    //aca tengo que poner los mockeos de los elegibility modules
    MockElegibilityModule public eModule1;
    MockElegibilityModule public eModule2;

    uint256[] eligibleTokens;

    uint256 public fork;
    uint256 public BLOCK_NUMBER = 16_947_805; // the block number where v1.hatsprotocol.eth was deployed;
    IHats public hats = IHats(0x9D2dfd6066d5935267291718E8AA16C8Ab729E9d); // v1.hatsprotocol.eth
    string public FACTORY_VERSION = "factory test version";
    string public MODULE_VERSION = "module test version";

    address public defaultModule = address(0x4a75);

    error ERC721Eligibility_InvalidHat();
    error ERC721Eligibility_NotHatAdmin();
    error ERC721Eligibility_HatImmutable();
    error ERC721Eligibility_TokenNotFound();

    function deployFactoryContracts() public {
        // deploy the clone factory
        // factory = new HatsModuleFactory{ salt: SALT}(hats, FACTORY_VERSION);
        factory = deployModuleFactory(hats, SALT, FACTORY_VERSION);

        // deploy the implementation via script
        DeployImplementation.prepare(MODULE_VERSION, false); // set to true to log deployment addresses
        DeployImplementation.run();
    }

    function createHats() public {
        vm.startPrank(dao);
        tophat = hats.mintTopHat(dao, "tophat", "");
        compoundHat =
            hats.createHat(tophat, "requires select ERC721 to wear", 5, defaultModule, defaultModule, true, "");
        vm.stopPrank();
    }

    function setUp() public virtual {
        // create and activate a fork, at BLOCK_NUMBER
        fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

        deployFactoryContracts();
        createHats();
    }

    function deployInstance(uint256 _eligibleHat, address module1, address module2) public virtual {
        // encode the other immutable args as packed bytes

        otherImmutableArgs = abi.encodePacked(module1, module2);
        // deploy the instance

        instance = CompoundEligibility(
            deployModuleInstance(factory, address(implementation), _eligibleHat, otherImmutableArgs, "deploy")
        );
    }
}

contract WithInstanceTest is CompoundEligibilityTest {
    function setUp() public virtual override {
        super.setUp();
        // set deploy params
        eModule1 = new MockElegibilityModule(eligibleInModule1,eligibleInModule1and2);
        eModule2 = new MockElegibilityModule(eligibleInModule2,eligibleInModule1and2);

        // deploy the instance
        deployInstance(compoundHat, address(eModule1), address(eModule2));

        // change the stakerHat's eligibility to instance
        vm.prank(dao);
        hats.changeHatEligibility(compoundHat, address(instance));
    }
}

contract Constructor is CompoundEligibilityTest {
    function test_version__() public {
        // version_ is the value in the implementation contract
        assertEq(implementation.version_(), MODULE_VERSION, "implementation version");
    }

    function test_version_reverts() public {
        vm.expectRevert();
        implementation.version();
    }
}

contract SetUp is WithInstanceTest {
    function test_immutables() public {
        assertEq(address(instance.EMODULE1()), address(eModule1), "ElegibilityModule 1");
        assertEq(address(instance.EMODULE2()), address(eModule2), "ElegibilityModule 2");
        assertEq(address(instance.HATS()), address(hats), "hats");
        assertEq(address(instance.IMPLEMENTATION()), address(implementation), "implementation");
        assertEq(instance.hatId(), compoundHat, "hatId");
    }
}

contract GetWearerStatus is WithInstanceTest {
    function _eligibilityCheck(address _wearer, bool expect) internal {
        (bool eligible, bool standing) = instance.getWearerStatus(_wearer, compoundHat);
        assertEq(eligible, expect, "eligible");
        console2.log("standing", standing);
        assertEq(standing, expect, "standing");
    }

    function test_getWearerStatus_true_and_false() public {
        _eligibilityCheck(eligibleInModule1, false);
    }

    function test_getWearerStatus_false_and_true() public {
        _eligibilityCheck(eligibleInModule2, false);
    }

    function test_getWearerStatus_false_and_false() public {
        _eligibilityCheck(ineligible, false);
    }

    function test_getWearerStatus_true_and_true() public {
        _eligibilityCheck(eligibleInModule1and2, true);
    }
}
