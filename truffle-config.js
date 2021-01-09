const HDWalletProvider = require('@truffle/hdwallet-provider');
const infuraKey = "4bd54433f50140e291db1b47cce3cb94";

const fs = require('fs');
let rinkebyMnemonic;
try {
    rinkebyMnemonic = fs.readFileSync(".secret").toString().trim();
} catch (err) {
    if (err.code !== 'ENOENT') {
        console.log(err);
    }
}

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },

    rinkeby: {
      provider: () =>
          new HDWalletProvider({
            mnemonic: {
              phrase: rinkebyMnemonic
            },
            providerOrUrl: "https://rinkeby.infura.io/v3/" + infuraKey,
            numberOfAddresses: 1,
            shareNonce: true,
          }),
      network_id: '4',
    }
  },

  compilers: {
    solc: {
      version: "0.7.0",
    }
  }
};
