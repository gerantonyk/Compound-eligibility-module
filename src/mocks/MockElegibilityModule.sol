// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { HatsEligibilityModule, HatsModule } from "hats-module/HatsEligibilityModule.sol";

contract MockElegibilityModule is HatsEligibilityModule {
    address elegible1;
    address elegible2;
    /// @notice Deploy the ERC721Eligibility implementation contract and set its version
    /// @dev This is only used to deploy the implementation contract, and should not be used to deploy clones

    constructor(address _elegible1, address _elegible2) HatsModule("1") {
        elegible1 = _elegible1;
        elegible2 = _elegible2;
    }

    function getWearerStatus(address wearer, uint256) public view override returns (bool eligible, bool standing) {
        bool elegible = (wearer == elegible1 || wearer == elegible2);

        return (elegible, elegible);
    }
}
