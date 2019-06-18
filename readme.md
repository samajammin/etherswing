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
$ yarn
```
