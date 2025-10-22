# Nivela Protocol

A sovereign borrowing protocol built on **BNB Smart Chain (BSC)** and compatible with other EVM networks.

## Technology Stack

- **Blockchain**: BNB Smart Chain + EVM-compatible chains  
- **Smart Contracts**: Solidity ^0.8.x  
- **Frontend**: React + TypeScript + Ethers.js  
- **Development**: Hardhat, OpenZeppelin libraries  

## Supported Networks

- **BNB Smart Chain Mainnet** (Chain ID: 56)  
- **BNB Smart Chain Testnet** (Chain ID: 97)  

## Contract Addresses

### Summary (per DappBay template)

| Network  | Core Contract (Vault) | Token Contract (NIV) | (Optional: Governance - veNIV) |
|----------|------------------------|----------------------|--------------------------------|
| BNB Mainnet | `0x2f2fe42c07f9d2c12a386edeb64efd23582ad9f6` | `0x56fc995646ab92a5128ceb2124721d122b3b9d90` | `0x4e6864c7007f407dc62db68f09023d58e93433fe` |

### Full Addresses

#### Main Contracts
- **nUSD.sol** — `0x9ae01bce99611a389645437208f199f4595df737`
- **DynamicInterestRate.sol** — `0x95e644288509600b01479e90b4296e3a7ffa0f8a`
- **Floor.sol** — `0xc0c7d5ec7e543536ba6042bacdfed9bdc5b6304a`
- **Lender.sol** — `0x674e2c3add04d21e7a2d7f8a14d00969e413b446`
- **Minter.sol** — `0xaf1cb1278b88609523484af028d2e3387abb5d67`
- **CircleStablecoinPSM.sol** — `0x577a547f24a8bb4ac9643644684dc883254c282a`
- **TetherStablecoinPSM.sol** — `0xe2d42ddb05e8ddb8b399b4fd2ad92f12e7470f1e`
- **StakednUSD.sol** — `0x6697db6332071f7c5b64577d0db9b7219ae09594`
- **NivelaVault.sol** — `0x2f2fe42c07f9d2c12a386edeb64efd23582ad9f6`
- **NIV.sol** — `0x56fc995646ab92a5128ceb2124721d122b3b9d90`
- **SupplyHangingCalculator.sol** — `0x7437cafc4aa1c2e929f49d2ccfca15bee7628913`
- **VoteEscrowedNIV.sol** — `0x4e6864c7007f407dc62db68f09023d58e93433fe`

#### Periphery Contracts
- **BaseContracts.sol** — `0xe7697d67f5b18f7f35a3f9882e108d2bb28e9ad6`
- **nUSDProvider.sol** — `0x8b1f0dd5d00e0673db1cbd560e0a79977492455b`
- **FeesDistributor.sol** — `0xaf4e56e11c207abfbef58127a630edcdf5656302`
- **FeesWithdrawer.sol** — `0x58d5b63d244cdf70ac63e6b1853bb6a2d1b197ee`
- **LenderOwner.sol** — `0xf28aa166dbf290f74412f42ef7b1344a476f7b8f`
- **LiquidationHelper.sol** — `0xc57982a0c4e40b36fbbd99db78e9a3abd1c88725`
- **MarketLens.sol** — `0x79a71f1fac2376a9187a7482a2122f6e21fb97c7`
- **MiscHelper.sol** — `0xbfe656fc84090593ca3decaa3d6c397132ed9914`
- **RepayHelper.sol** — `0x0f006aafb6768d28a8b580911086ac998745a7a6`
- **StableOwner.sol** — `0x7af653b8135005c20b238963114103744f84d78f`

#### Oracle Contracts
- **OracleApi3ReaderWBNB.sol** — `0x9c12eb5214423205d860665201bfbcf2f0b1f774`
- **OracleApi3ReadertBTCB.sol** — `0x870e8516df13f54d6750334b702b0cf08bb3dfc7`
- **OracleApi3ReaderFDUSD.sol** — `0xa7f2bfe2c91d1c188c2163d659d4f1a41440cee8`
- **OracleApi3ReaderUSDC.sol** — `0x85580cbaae6607781fcf1b09925924b97c9b3a2e`
- **OracleApi3ReaderUSDT.sol** — `0x2E72Eba8143650Dd4dDD98B9206ef3643a0737B4`
- **OracleChainlink.sol** — `0x90f8168ac58b6a11e69976d91d828e6ff599c0db`
- **OracleFloorPrice.sol** — `0xae2a7a061ad6d3f9bf08436941cca60238253f0b`

## Features

- High-LTV borrowing with quasi-fixed interest rates  
- Over-collateralized stablecoin (nUSD) redeemable 1:1 with USDC via PSM  
- Staking & revenue sharing via stnUSD  
- Governance and collateral boosting with veNIV  
- Permissionless and censorship-resistant design  
- Gas-efficient design for BNB Smart Chain  

## Links

- Website: https://nivela.fi  
- Documentation: https://nivelafi.gitbook.io/docs  
- Twitter: https://x.com/nivelafi  

## Configuration Evidence

The repository includes a Hardhat configuration targeting **BNB Smart Chain** RPC endpoints:

```js
networks: {
  bsc: {
    url: "https://bsc-dataseed.binance.org/",
    chainId: 56
  },
  bsctestnet: {
    url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
    chainId: 97
  }
}
```