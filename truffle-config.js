module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",  // Localhost
      port: 7545,         // Ganache's default port
      network_id: "*",    // Any network
    },
    // ...
  },
  
  compilers: {
    solc: {
      version: "0.8.21",  // Solidity compiler version
    }
  },
  
};
