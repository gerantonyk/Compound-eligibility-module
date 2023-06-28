// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { HatsEligibilityModule, HatsModule } from "hats-module/HatsEligibilityModule.sol";
import { IERC721 } from "@openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

/**
 * @title ERC721Eligibility
 * @author WhiteOakKong
 * @notice A Hats Protocol eligibility contract that allows owners of specific ERC721 tokens to be eligible for a hat
 */

contract ERC721Eligibility is HatsEligibilityModule {
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error ERC721Eligibility_InvalidHat();
    /// @notice Thrown when a non-admin tries to call an admin restricted function.
    error ERC721Eligibility_NotHatAdmin();
    /// @notice Thrown when a change to the eligible tokens is attempted on an immutable hat.
    error ERC721Eligibility_HatImmutable();
    /// @notice Thrown if a token is not found in the eligibility array
    error ERC721Eligibility_TokenNotFound();

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a ERC721Eligibility for `hatId` and `token` is deployed to address `instance`
    event ERC721Eligibility_Deployed(uint256 hatId, address instance, address token, uint256[] eligibleTokens);
    /// @notice Emitted when an array of `tokens` is added to the eligibility for `hatId`
    event ERC721Eligibility_TokensAdded(uint256 hatId, uint256[] tokens);
    /// @notice Emitted when an array of `tokens` is removed from the eligibility for `hatId`
    event ERC721Eligibility_TokenRemoved(uint256 hatId, uint256 token);

    /*//////////////////////////////////////////////////////////////
                          PUBLIC CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * This contract is a clone with immutable args, which means that it is deployed with a set of
     * immutable storage variables (ie constants). Accessing these constants is cheaper than accessing
     * regular storage variables (such as those set on initialization of a typical EIP-1167 clone),
     * but requires a slightly different approach since they are read from calldata instead of storage.
     *
     * Below is a table of constants and their location.
     *
     * For more, see here: https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args
     *
     * --------------------------------------------------------------------+
     * CLONE IMMUTABLE "STORAGE"                                           |
     * --------------------------------------------------------------------|
     * Offset  | Constant        | Type    | Length  |                     |
     * --------------------------------------------------------------------|
     * 0       | IMPLEMENTATION  | address | 20      |                     |
     * 20      | HATS            | address | 20      |                     |
     * 40      | hatId           | uint256 | 32      |                     |
     * 72      | TOKEN           | address | 20      |                     |
     * --------------------------------------------------------------------+
     */

    /**
     * @dev The first three getters are inherited from HatsEligibilityModule
     */
    function TOKEN() public pure returns (IERC721) {
        return IERC721(_getArgAddress(72));
    }

    /*//////////////////////////////////////////////////////////////
                          MUTABLE STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The tokens that grant eligibility for the hat
    /// @dev NOTE: If there are tokens that are more likely to be used for eligibility status than others, attempts
    /// should be made to add them first. This will improve efficiency.
    uint256[] public eligibleTokens;

    /*//////////////////////////////////////////////////////////////
                            INITIALIZER
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc HatsModule
     */
    function setUp(bytes calldata _initdata) public override initializer {
        // decode the _initData bytes and set the values in storage
        uint256[] memory _tokens = abi.decode(_initdata, (uint256[]));
        // set the initial values in storage
        uint256 len = _tokens.length;
        for (uint256 i = 0; i < len; i++) {
            eligibleTokens.push(_tokens[i]);
        }

        // log the deployment & setup
        emit ERC721Eligibility_Deployed(hatId(), address(this), address(TOKEN()), eligibleTokens);
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Deploy the ERC721Eligibility implementation contract and set its version
    /// @dev This is only used to deploy the implementation contract, and should not be used to deploy clones
    constructor(string memory _version) HatsModule(_version) { }

    /*//////////////////////////////////////////////////////////////
                      HATS ELIGIBILITY FUNCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc HatsEligibilityModule
     */

    function getWearerStatus(
        address _wearer,
        uint256 /* _hatId */
    )
        public
        view
        override
        returns (bool eligible, bool standing)
    {
        standing = true;

        // set interface for ERC721 token
        // IERC721 token = TOKEN();
        address token = address(TOKEN());

        //cache the length of eligibleTokens
        uint256 len = eligibleTokens.length;

        address owner;

        // @solidity memory-safe-assembly
        assembly {
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                //load eligibleTokens array slot
                let slot := eligibleTokens.slot
                mstore(0x00, slot)
                //calculate location of eligibleTokens[i]
                let location := keccak256(0x00, 0x20)
                //storing ownerOf selector in scratch space
                mstore(0x00, 0x6352211e)
                //storing token id in scratch space
                mstore(0x20, sload(add(location, i)))
                // external call: token.ownerOf(tokenId)
                owner := staticcall(gas(), token, 28, 0x40, 0x00, 0x20)
                owner := mload(0x00)
                //check if owner is equal to _wearer
                if eq(owner, _wearer) {
                    //set eligible to true
                    eligible := 1
                    //break the loop
                    i := mload(len)
                }
            }
        }
    }

    /**
     * //STANDARD IMPLEMENTATION FOR REFERENCE
     * function getWearerStatus(address _wearer,uint256 /* _hatId ) public view override returns (bool eligible, bool
     * standing) {
     *     //standing always returns true
     *     standing = true;
     *
     *     // set interface for ERC721 token
     *     IERC721 token = TOKEN();
     *
     *     //cache the length of eligibleTokens
     *     uint256 len = eligibleTokens.length;
     *
     *     //interate through the array of eligible token IDs. If any of them are owned by the _wearer, they are
     * eligible.
     *     // The loop breaks upon finding the first eligible token.
     *     for (uint256 i = 0; i < len; i++) {
     *         token.ownerOf(eligibleTokens[i]) returns (address owner) {
     *             if (owner == _wearer) {
     *                 eligible = true;
     *                 break;
     *             }
     *         }
     *     }
     * }
     */

    function getAllEligibleTokens() external view returns (uint256[] memory) {
        return eligibleTokens;
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Remove a token from the list of eligible tokens
     * @param tokenID The ID of the token to remove
     */
    //@TODO add admin and mutability functionality
    function removeEligibleToken(uint256 tokenID) external onlyHatAdmin hatIsMutable {
        uint256 len = eligibleTokens.length;
        for (uint256 i = 0; i < len; i++) {
            //check if eligibleTokens[i] is equal to tokenID
            if (eligibleTokens[i] == tokenID) {
                //replace eligibleTokens[i] with the last element in the array
                eligibleTokens[i] = eligibleTokens[eligibleTokens.length - 1];
                //remove the last element in the array
                eligibleTokens.pop();
                //emit event
                emit ERC721Eligibility_TokenRemoved(hatId(), tokenID);
                //break the loop and return early
                return;
            }
        }
        revert ERC721Eligibility_TokenNotFound();
    }

    /**
     * @notice Add a token to the list of eligible tokens
     * @param _tokenIds An array of IDs to add.
     * @dev This function does not check whether the tokens are already eligible
     */
    function addEligibleTokens(uint256[] calldata _tokenIds) external onlyHatAdmin hatIsMutable {
        uint256 len = _tokenIds.length;
        for (uint256 i = 0; i < len; i++) {
            eligibleTokens.push(_tokenIds[i]);
        }
        emit ERC721Eligibility_TokensAdded(hatId(), _tokenIds);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns whether this instance of ERC721Eligibility's hatId is mutable
     */
    function _hatIsMutable() internal view returns (bool _isMutable) {
        (,,,,,,, _isMutable,) = HATS().viewHat(hatId());
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyHatAdmin() {
        if (!HATS().isAdminOfHat(msg.sender, hatId())) {
            revert ERC721Eligibility_NotHatAdmin();
        }
        _;
    }

    modifier hatIsMutable() {
        if (!_hatIsMutable()) revert ERC721Eligibility_HatImmutable();
        _;
    }
}
