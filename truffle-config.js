/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura API
 * keys are available for free at: infura.io/register
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

// const HDWallet = require('truffle-hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  // quiet: true, // uncomment to silence compiler & migration logs
  networks: {
    // environment when running `truffle develop`
    develop: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*' // Match any network id
    },
    // environment when running `truffle migrate`
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*' // Match any network id
    },
    // environment using mainnet contracts & data @ block 8159055 in local development
    // start the ganache chain in terminal:
    // ganache-cli --fork https://mainnet.infura.io/v3/{your-infura-project-id}
    // then run:
    // truffle console --network mainlocal
    mainlocal: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '1',
      skipDryRun: true,
      gas: 6000000
    }
    // TODO not needed...?
    // needed for running 'migrate' on 'mainlocal'... truffle adds '-fork':
    // https://github.com/trufflesuite/truffle/blob/81a290f1e1beda24bd9deb10999a07ac64a8d602/packages/truffle-environment/environment.js#L40
    // 'mainlocal-fork': {
    //   // for local development using mainnet contracts & data @ block 8159055
    //   // start the ganache chain in terminal:
    //   // ganache-cli --fork https://mainnet.infura.io/v3/{your-infura-project-id}
    //   host: '127.0.0.1',
    //   port: 8545,
    //   network_id: '1',
    //   skipDryRun: true,
    //   gas: 6000000
    // }
  },
  compilers: {
    solc: {
      version: '0.4.24', // for MakerDAO contracts
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};
