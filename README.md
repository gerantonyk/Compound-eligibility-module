# ERC721Eligibility

ERC721Eligibility is an eligibility module for [Hats Protocol](https://github.com/hats-protocol/hats-protocol). It
requires wearers of a given Hat to own at least one token from a set of TokenIDs from a set ERC721 Contract in order to
be eligible.

## ERC721Eligibility Details

ERC721Eligibility inherits from the
[HatsEligibilityModule](https://github.com/Hats-Protocol/hats-module#hatseligibilitymodule) base contract, from which it
receives two major properties:

- It can be cheaply deployed via the [HatsModuleFactory](https://github.com/Hats-Protocol/hats-module#hatsmodulefactory)
  minimal proxy factory, and
- It implements the
  [IHatsEligibility](https://github.com/Hats-Protocol/hats-protocol/blob/main/src/Interfaces/IHatsEligibility.sol)
  interface

### Setup

A ERC721Eligibility instance requires several parameters to be set at deployment, passed to the
`HatsModuleFactory.createHatsModule()` function in various ways.

#### Immutable values

- `hatId`: The id of the hat to which this the instance will be attached as an eligibility module, passed as itself
- `TOKEN`: The address of the ERC721-compatible contract, abi-encoded (packed) and passed as `_otherImmutableArgs`

The following immutable values will also automatically be set within the instance at deployment:

- `IMPLEMENTATION`: The address of the ERC721Eligibility implementation contract
- `HATS`: The address of the Hats Protocol contract

#### Initial state values

The following are abi-encoded (unpacked) and then passed to the `HatsModuleFactory.createHatsModule()` function as
`_initData`. These values can be changed after deployment by an admin of the `hatId` hat.

- `eligibileTokens`: An array of uin256 tokenIds that will grant their owner eligibility

### Admin Functionality

Mutable hats grant their admins the ability to modify eligible tokens.

If called by an admin, `addEligibleTokens()` adds an array of eligible tokens to the existing array. The function does
NOT check for duplication, so care should be taken to ensure duplicate values are not passed. Duplicate values may
result in increased gas consumption and should be avoided.

If called by an admin `removeEligibleToken()` removes a specific tokenID from the array `eligibleTokens`. If the token
is not found in the array, it will revert.

### Changing Parameters

The following parameters can be changed after deployment by an admin of the `hatId` hat. Changes are only allowed while
the `hatId` is mutable.

- `eligibleTokens`, by calling the `addEligibleTokens()` or `removeEligibleToken()` functions.

NOTE: duplicate values inputted into eligibleTokens will result in increased gas consumption and should be avoided.

## Development

This repo uses Foundry for development and testing. To get started:

1. Fork the project
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. To compile the contracts, run `forge build`
4. To test, run `forge test`
