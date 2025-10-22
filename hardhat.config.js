/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",
  networks: {
    // BNB Smart Chain Mainnet
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56
      // accounts: [process.env.DEPLOYER_PK] // optional
    },
    // BNB Smart Chain Testnet
    bsctestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97
      // accounts: [process.env.DEPLOYER_PK_TESTNET] // optional
    }
  }
};