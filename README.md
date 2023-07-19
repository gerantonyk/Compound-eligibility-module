# CompoundEligibility

CompoundEligibility is an eligibility module for [Hats Protocol](https://github.com/hats-protocol/hats-protocol). In this module, a Hat can have multiple eligibility criteria. The module has two immutable arguments to add two desired modules that need to be combined. In case you want to combine more than 2 modules, you can use a desired eligibility module as the first argument and a Compound Eligibility module as the second parameter, allowing the association of 2 new modules.

There are two different modules: one for conjunction (AND) and a second one for disjunction (OR).

## CompoundEligibility Details

ERC721Eligibility inherits from the
[HatsEligibilityModule](https://github.com/Hats-Protocol/hats-module#hatseligibilitymodule) base contract, from which it
receives two major properties:

- It can be cheaply deployed via the [HatsModuleFactory](https://github.com/Hats-Protocol/hats-module#hatsmodulefactory)
  minimal proxy factory, and
- It implements the
  [IHatsEligibility](https://github.com/Hats-Protocol/hats-protocol/blob/main/src/Interfaces/IHatsEligibility.sol)
  interface

### Setup

A CompoundEligibility instance requires several parameters to be set at deployment, passed to the
`HatsModuleFactory.createHatsModule()` function in various ways.

#### Immutable values

- `hatId`: The id of the hat to which this the instance will be attached as an eligibility module, passed as itself
- `EMODULE1`: The address of the first Elegibility module contract to be combined, abi-encoded (packed) and passed as `_otherImmutableArgs`
- `EMODULE2`: The address of the second Elegibility module contract to be combined, abi-encoded (packed) and passed as `_otherImmutableArgs`
The following immutable values will also automatically be set within the instance at deployment:
- `IMPLEMENTATION`: The address of the CompoundEligibility implementation contract
- `HATS`: The address of the Hats Protocol contract

## Development

This repo uses Foundry for development and testing. To get started:

1. Fork the project
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. To compile the contracts, run `forge build`
4. To test, run `forge test`

## Implementation

Implementation:

CompoundEligibilityModule: 0xd0a9C16260244abAe2cAeC206C327ADE7Dad4902
DisjunctionEligibilityModule: 0xA8235882E63F7B8E59B8993046a5A2520776fFf3