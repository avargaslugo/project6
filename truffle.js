const HDWalletProvider = require('truffle-hdwallet-provider');
const infuraKey = "infurakey";
//
// const fs = require('fs');
const mnemonic = 'better cruise rely forum syrup remember agree travel lottery resist puzzle exit';


module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },

    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${infuraKey}`),
        network_id: 4,       // rinkeby's id
        gas: 4500000,        // rinkeby has a lower block limit than mainnet
        gasPrice: 10000000000
    }
  }
};