## Trustless Bridge
Transferring tokens across Layer 2 (L2) networks, particularly between fundamentally different L2 groups like optimistic rollups and ZK-rollups, often requires cross-chain messaging protocols such as Axelar or Layer 0. However, these protocols come with specific trust assumptions (e.g., reliance on oracles), which, if compromised, can lead to significant vulnerabilities or losses during cross-chain transactions.

Scroll introduces a groundbreaking feature, L1SLOAD, which enables direct reading of data from Layer 1 (L1). This innovation eliminates the need for cross-chain messaging protocols when bridging assets from other L2s to Scroll, paving the way for a truly trustless bridge.

The Trustless Bridge Project demonstrates how assets can be securely and trustlessly transferred from Optimism to Scroll using the L1SLOAD precompile. This implementation highlights a new era of seamless, decentralized, and trustless interoperability between L2 ecosystems.

https://trustless-bridge-frontend.vercel.app/bridge

### Demo video

https://youtu.be/07ohcE1I7_Y

### Build

```shell
$ npm install
$ forge build
```

### Test

```shell
$ forge test
```
