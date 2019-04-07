const HDWalletProvider = require('truffle-hdwallet-provider');
const infuraKey = "637e1b67b327486a9d2b3e8185bfc0ef";
//
// const fs = require('fs');
const mnemonic = 'parent leopard equip settle gadget used acquire absorb reject unaware force annual';


module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 9545,
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