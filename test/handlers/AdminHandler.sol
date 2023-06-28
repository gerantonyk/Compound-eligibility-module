// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import { Test, console2, DSTest, TestBase, StdCheats, StdUtils } from "forge-std/Test.sol";
import { ERC721Eligibility, IERC721 } from "src/ERC721EligibilityModule.sol";
import { IHats } from "hats-protocol/Interfaces/IHats.sol";
import { AddressSet, LibAddressSet } from "test/handlers/LibHandler.sol";

interface IAdminHandler {
    function addEligibleTokens(uint256[] calldata _tokenIds) external;
    function removeEligibileToken(uint256 tokenID) external;
    function numCalls(bytes32 _func) external returns (uint256);
}

contract AdminHandler is IAdminHandler, TestBase, DSTest, StdCheats, StdUtils {
    using LibAddressSet for AddressSet;

    /*//////////////////////////////////////////////////////////////
                            CONSTANTS
    //////////////////////////////////////////////////////////////*/

    ERC721Eligibility public immutable erc721Eligibility;
    IHats public immutable HATS;

    /*//////////////////////////////////////////////////////////////
                            GHOST VARS
    //////////////////////////////////////////////////////////////*/

    // call tracker
    mapping(bytes32 => uint256) public numCalls;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(ERC721Eligibility _erc721Eligibility) {
        erc721Eligibility = _erc721Eligibility;
        HATS = erc721Eligibility.HATS();
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function addEligibleTokens(uint256[] calldata _tokenIds) public virtual countCall {
        vm.prank(msg.sender);
        erc721Eligibility.addEligibleTokens(_tokenIds);

        console2.log("number of eligible tokens added ", _tokenIds.length);
    }

    function removeEligibileToken(uint256 tokenId) public virtual countCall {
        vm.prank(msg.sender);
        erc721Eligibility.removeEligibleToken(tokenId);

        console2.log("TokenID ", tokenId, " removed");
    }

    /*//////////////////////////////////////////////////////////////
                            CALL ACCOUNTING
    //////////////////////////////////////////////////////////////*/

    modifier countCall() {
        numCalls[msg.sig]++;
        _;
    }
}

contract BoundedAdminHandler is AdminHandler {
    constructor(ERC721Eligibility _erc721Eligibility) AdminHandler(_erc721Eligibility) { }

    function addEligibleTokens(uint256[] calldata _tokenIds) public override countCall {
        // mock msg.sender as the admin
        vm.mockCall(
            address(HATS),
            abi.encodeWithSelector(IHats.isAdminOfHat.selector, msg.sender, erc721Eligibility.hatId()),
            abi.encode(true)
        );
        super.addEligibleTokens(_tokenIds);
    }

    function removeEligibileToken(uint256 tokenID) public override countCall {
        // mock msg.sender as the admin
        vm.mockCall(
            address(HATS),
            abi.encodeWithSelector(IHats.isAdminOfHat.selector, msg.sender, erc721Eligibility.hatId()),
            abi.encode(true)
        );

        super.removeEligibileToken(tokenID);
    }
}
