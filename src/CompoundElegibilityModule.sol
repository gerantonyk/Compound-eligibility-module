// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { HatsEligibilityModule, HatsModule } from "hats-module/HatsEligibilityModule.sol";
/**
 * @title CompoundEligibility
 * @author gerantonyk
 * @notice A Hats Protocol eligibility contract that allows owners to specifi multiple Elefibility Modules
 */

contract CompoundEligibility is HatsEligibilityModule {
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
     * 72      | EMODULE1        | address | 20      |                     |
     * 92      | EMODULE2        | address | 20      |                     |
     * --------------------------------------------------------------------+
     */

    /**
     * @dev The first three getters are inherited from HatsEligibilityModule
     */
    function EMODULE1() public pure returns (HatsEligibilityModule) {
        return HatsEligibilityModule(_getArgAddress(72));
    }

    function EMODULE2() public pure returns (HatsEligibilityModule) {
        return HatsEligibilityModule(_getArgAddress(92));
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
        uint256 _hatId
    )
        public
        view
        override
        returns (bool eligible, bool standing)
    {
        (bool eligible1,) = EMODULE1().getWearerStatus(_wearer, _hatId);

        (bool eligible2,) = EMODULE2().getWearerStatus(_wearer, _hatId);

        return (eligible1 && eligible2, true);
    }
}
