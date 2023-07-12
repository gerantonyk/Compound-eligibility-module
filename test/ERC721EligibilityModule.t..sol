// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.19;

// import { Test, console2 } from "forge-std/Test.sol";
// import { ERC721Eligibility } from "src/ERC721EligibilityModule.sol";
// import { DeployImplementation } from "script/ERC721EligibilityModule.s.sol";
// import {
//     HatsModuleFactory, IHats, deployModuleInstance, deployModuleFactory
// } from "hats-module/utils/DeployFunctions.sol";
// import { MockERC721 } from "src/mocks/MockERC721.sol";

// contract ERC721EligibilityTest is Test, DeployImplementation {
//     HatsModuleFactory public factory;
//     ERC721Eligibility public instance;
//     bytes public otherImmutableArgs;
//     bytes public initData;

//     ERC721EligibilityHarness public harnessImpl;
//     ERC721EligibilityHarness public harnessInstance;

//     uint256 public tophat;
//     uint256 public erc721Hat;
//     address public eligibility = makeAddr("eligibility");
//     address public toggle = makeAddr("toggle");
//     address public dao = makeAddr("dao");
//     address public notAdmin = makeAddr("notAdmin");

//     address public eligible1 = makeAddr("eligible1");
//     address public eligible2 = makeAddr("eligible2");
//     address public eligible3 = makeAddr("eligible3");
//     address public ineligible = makeAddr("ineligible");

//     MockERC721 public token;

//     uint256[] eligibleTokens;

//     uint256 public fork;
//     uint256 public BLOCK_NUMBER = 16_947_805; // the block number where v1.hatsprotocol.eth was deployed;
//     IHats public hats = IHats(0x9D2dfd6066d5935267291718E8AA16C8Ab729E9d); // v1.hatsprotocol.eth
//     string public FACTORY_VERSION = "factory test version";
//     string public MODULE_VERSION = "module test version";

//     address public defaultModule = address(0x4a75);

//     error ERC721Eligibility_InvalidHat();
//     error ERC721Eligibility_NotHatAdmin();
//     error ERC721Eligibility_HatImmutable();
//     error ERC721Eligibility_TokenNotFound();

//     event ERC721Eligibility_Deployed(uint256 hatId, address instance, address token, uint256[] eligibleTokens);
//     event ERC721Eligibility_TokensAdded(uint256 hatId, uint256[] tokens);
//     event ERC721Eligibility_TokenRemoved(uint256 hatId, uint256 token);

//     function deployFactoryContracts() public {
//         // deploy the clone factory
//         // factory = new HatsModuleFactory{ salt: SALT}(hats, FACTORY_VERSION);
//         factory = deployModuleFactory(hats, SALT, FACTORY_VERSION);

//         // deploy the implementation via script
//         DeployImplementation.prepare(MODULE_VERSION, false); // set to true to log deployment addresses
//         DeployImplementation.run();
//     }

//     function createHats() public {
//         vm.startPrank(dao);
//         tophat = hats.mintTopHat(dao, "tophat", "");
//         erc721Hat = hats.createHat(tophat, "requires select ERC721 to wear", 5, defaultModule, defaultModule, true,
// "");
//         vm.stopPrank();
//     }

//     function setUp() public virtual {
//         // create and activate a fork, at BLOCK_NUMBER
//         fork = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

//         deployFactoryContracts();
//         createHats();
//     }

//     function deployInstance(uint256 _eligibleHat, address _token, uint256[] memory _eligibleTokens) public virtual {
//         // encode the other immutable args as packed bytes
//         otherImmutableArgs = abi.encodePacked(_token);
//         // encoded the initData as unpacked bytes
//         initData = abi.encode(_eligibleTokens);
//         // deploy the instance

//         instance = ERC721Eligibility(
//             deployModuleInstance(factory, address(implementation), _eligibleHat, otherImmutableArgs, initData)
//         );
//     }
// }

// contract WithInstanceTest is ERC721EligibilityTest {
//     function setUp() public virtual override {
//         super.setUp();
//         // set deploy params
//         token = new MockERC721();
//         eligibleTokens = new uint256[](10);
//         for (uint256 i = 0; i < 10; i++) {
//             eligibleTokens[i] = i;
//         }

//         token.safeMint(eligible1);
//         token.safeMint(eligible2);
//         token.safeMint(eligible3);

//         // deploy the instance
//         deployInstance(erc721Hat, address(token), eligibleTokens);

//         // change the stakerHat's eligibility to instance
//         vm.prank(dao);
//         hats.changeHatEligibility(erc721Hat, address(instance));
//     }
// }

// contract ERC721EligibilityHarness is ERC721Eligibility {
//     constructor(string memory _version) ERC721Eligibility(_version) { }

//     function isMutable() public view hatIsMutable returns (bool) {
//         return true;
//     }

//     function isHatAdmin() public view onlyHatAdmin returns (bool) {
//         return true;
//     }
// }

// // contract HarnessTest is ERC721EligibilityTest {
// //     ERC721EligibilityHarness public harness;

// //     function setUp() public virtual override {
// //         super.setUp();
// //         // deploy the harness implementation
// //         harnessImpl = new ERC721EligibilityHarness("harness version");
// //         // deploy an instance of the harness and initialize it with the same initData as `instance`
// //         harnessInstance = ERC721EligibilityHarness(
// //             deployModuleInstance(factory, address(harnessImpl), erc721Hat, otherImmutableArgs, initData)
// //         );
// //     }
// // }

// // contract Internal_hatIsMutable is HarnessTest {
// //     function test_mutable_succeeds() public {
// //         assertTrue(harnessInstance.isMutable());
// //     }

// //     function test_immutable_reverts() public {
// //         // change the stakerHat to be immutable
// //         vm.prank(dao);
// //         hats.makeHatImmutable(erc721Hat);
// //         // expect a revert
// //         vm.expectRevert(ERC721Eligibility_HatImmutable.selector);
// //         harnessInstance.isMutable();
// //     }
// // }

// // contract Internal_onlyHatAdmin is HarnessTest {
// //     function test_hatAdmin_succeeds() public {
// //         vm.prank(dao);
// //         assertTrue(harnessInstance.isHatAdmin());
// //     }

// //     function test_nonHatAdmin_reverts() public {
// //         // expect a revert
// //         vm.expectRevert(ERC721Eligibility_NotHatAdmin.selector);
// //         vm.prank(notAdmin);
// //         harnessInstance.isHatAdmin();
// //     }
// // }

// // contract Constructor is ERC721EligibilityTest {
// //     function test_version__() public {
// //         // version_ is the value in the implementation contract
// //         assertEq(implementation.version_(), MODULE_VERSION, "implementation version");
// //     }

// //     function test_version_reverts() public {
// //         vm.expectRevert();
// //         implementation.version();
// //     }
// // }

// contract SetUp is WithInstanceTest {
//     function test_initData() public {
//         assertEq(instance.getAllEligibleTokens(), eligibleTokens, "eligibleTokens");
//     }

//     function test_immutables() public {
//         assertEq(address(instance.TOKEN()), address(token), "token");
//         assertEq(address(instance.HATS()), address(hats), "hats");
//         assertEq(address(instance.IMPLEMENTATION()), address(implementation), "implementation");
//         assertEq(instance.hatId(), erc721Hat, "hatId");
//     }

//     function test_emitDeployedEvent() public {
//         // prepare to deploy a new instance for a different hat
//         erc721Hat = 1;
//         // predict the new instance address
//         address predicted = factory.getHatsModuleAddress(address(implementation), erc721Hat, otherImmutableArgs);
//         // expect the event
//         vm.expectEmit(true, true, true, true);
//         emit ERC721Eligibility_Deployed(erc721Hat, predicted, address(token), eligibleTokens);

//         deployInstance(erc721Hat, address(token), eligibleTokens);
//     }
// }

// // contract GetWearerStatus is WithInstanceTest {
// //     function _eligibilityCheck(address _wearer, bool expect) internal {
// //         (bool eligible, bool standing) = instance.getWearerStatus(_wearer, erc721Hat);
// //         assertEq(eligible, expect, "eligible");
// //         assertEq(standing, true, "standing");
// //     }

// //     function test_getWearerStatus_true_true() public {
// //         _eligibilityCheck(eligible1, true);
// //     }

// //     function test_getWearerStatus_false_true() public {
// //         _eligibilityCheck(ineligible, false);
// //     }
// // }

// // contract AdminFunctions is WithInstanceTest {
// //     function test_removeEligibleToken() public {
// //         uint256[] memory initial = instance.getAllEligibleTokens();
// //         assertEq(initial.length, 10, "initial length");

// //         vm.startPrank(dao);
// //         instance.removeEligibleToken(initial[8]);
// //         vm.stopPrank();

// //         uint256[] memory afterCount = instance.getAllEligibleTokens();
// //         assertEq(afterCount.length, 9, "after length");
// //     }

// //     function test_removeEligibleToken_InvalidToken() public {
// //         vm.expectRevert(ERC721Eligibility_TokenNotFound.selector);
// //         vm.startPrank(dao);
// //         instance.removeEligibleToken(100);
// //         vm.stopPrank();
// //     }

// //     function test_addEligibletokens() public {
// //         uint256[] memory initial = instance.getAllEligibleTokens();
// //         assertEq(initial.length, 10, "initial length");

// //         vm.startPrank(dao);
// //         uint256[] memory tokensToAdd = new uint256[](2);
// //         tokensToAdd[0] = 10;
// //         tokensToAdd[1] = 11;
// //         instance.addEligibleTokens(tokensToAdd);
// //         vm.stopPrank();

// //         uint256[] memory afterCount = instance.getAllEligibleTokens();
// //         assertEq(afterCount.length, 12, "after length");
// //         assertEq(afterCount[10], 10);
// //         assertEq(afterCount[11], 11);
// //     }
// // }
