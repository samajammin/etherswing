# EtherSwing

## Prerequisites

You will need the following properly installed on your computer:

- [Git](https://git-scm.com/)
- [Node.js v8+ LTS](https://nodejs.org/en/)

## Installation

Install [yarn](https://yarnpkg.com/lang/en/docs/install) (or use NPM if you prefer):

```
brew install yarn
```

Install [Truffle](https://truffleframework.com/truffle):

```
yarn global add truffle
```

Ensure you have truffle 5. Running `truffle version` should output look something like:

```
Truffle v5.0.21 (core: 5.0.21)
Solidity v0.5.0 (solc-js)
Node v10.13.0
Web3.js v1.0.0-beta.37
```

[Install Vyper](https://vyper.readthedocs.io/en/latest/installing-vyper.html) with a virtualenv

Once your virtualenv is activated, running `vyper --version` should output:

```
0.1.0b10
```

Install project dependencies

```bash
yarn
```

## Development

In order to run the `mainlocal` network, set up a local [ganache](https://github.com/trufflesuite/ganache-cli) chain that is a fork of Ethereum's mainnet. The easiet way is to create an [Infura](https://infura.io) project. Then run:

```bash
ganache-cli --fork https://mainnet.infura.io/v3/{your-infura-project-id}@8159055
```

This will fork the mainnet at block 8159055, allowing you to interact with mainnet contracts and storage (e.g. the MakerDAO system). When using Truffle, make sure to run:

```bash
truffle console --network mainlocal
```

Otherwise, running `truffle develop` will spin up a separate ganache instance.
