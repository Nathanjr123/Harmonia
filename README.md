## Harmonia Project

### Overview

The Harmonia Project is a Solidity-based project designed to manage a custom ERC20 token (`HarmoniaToken`) and ERC721 NFTs (`HarmoniaNFT`). The token includes unique reward mechanisms, where users earn rewards based on listening time, and the reward rate decays over time. The project is developed and tested using Foundry, a powerful Ethereum development framework.

### Foundry

**Foundry is a blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat, and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions, and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose Solidity REPL.

### Documentation

For more information on Foundry, refer to the [Foundry Book](https://book.getfoundry.sh/).

### Project Structure

-   **`src/`**: Contains the main Solidity contracts (`HarmoniaToken.sol`, `HarmoniaNFT.sol`).
-   **`test/`**: Contains the test files (`HarmoniaTokenTest.sol`, `HarmoniaNFTTest.sol`), which are written using Forge.
-   **`script/`**: Used for deployment scripts and other custom scripts.

### Key Features

-   **Dynamic Reward Rate**: The `HarmoniaToken` contract includes a reward rate that decays over time. The reward rate decreases by a specified percentage every 30 days, calculated using the `getCurrentRewardRate` function.
-   **Listening Time Rewards**: The `HarmoniaToken` rewards users based on their listening time, tracked through the `updateListeningTime` function.
-   **Minting & Burning**: Both `HarmoniaToken` and `HarmoniaNFT` contracts support minting and burning functionalities.
-   **Ownership and Permissions**: The contracts utilize OpenZeppelin's `Ownable` contract to manage ownership and permissions for critical functions like minting.

### Setup & Usage

#### Build

Compile the Solidity contracts:

```shell
$ forge build
```

#### Test

Run the test suite:

```shell
$ forge test
```



#### Gas Snapshots

Generate gas usage snapshots for the contract functions:

```shell
$ forge snapshot
```

#### Local Node

Start a local Ethereum node:

```shell
$ anvil
```

#### Deploy

Deploy contracts using a script:

```shell
$ forge script script/YourScript.s.sol:YourScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

#### Interact with Contracts

Use Cast to interact with deployed contracts:

```shell
$ cast <subcommand>
```

#### Help

Get help for any Foundry tool:

```shell
$ forge --help
$ anvil --help
$ cast --help
```

### Testing

The `HarmoniaTokenTest` contract includes comprehensive tests for the following functionalities:

- Initial token supply and ownership verification.
- Minting and burning of tokens, with checks for proper authorization and edge cases.
- Reward calculation based on dynamic reward rates, using listening time as a metric.
- Transfer of NFTs and associated reward distribution to both current and original owners.

Ensure all tests pass before deploying or modifying the contract.

---

This README should give a clear overview of your project and how to work with it using Foundry. Let me know if you need further adjustments!