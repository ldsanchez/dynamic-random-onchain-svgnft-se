# 🏗 scaffold-ETH - Dynamic Random SVG NFT

> A Fully On-Chain Random SVG NFT based on Boring Avatars art, that when minted are HAPPY or SAD based on the ETH price given by the Chainlink EthUsd DataFeed in respect to a Threshold! 🚀

![Ethereum_App](https://user-images.githubusercontent.com/5996795/170857323-42e2dac0-3dce-47fe-bf94-e71302af8261.png)

# 🏄‍♂️ Quick Start

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone/fork 🏗 scaffold-eth: Multisig Wallet Factory

```bash
git clone https://github.com/ldsanchez/dynamic-random-onchain-svgnft-se.git
```

> install and start your 👷‍ Hardhat chain:

```bash
cd dynamic-random-onchain-svgnft-se
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd dynamic-random-onchain-svgnft-se
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
cd dynamic-random-onchain-svgnft-se
yarn deploy
```

🔏 Edit your smart contract `DynamicRSVGNFT.sol` in `packages/hardhat/contracts`

📝 Edit your frontend `App.jsx` in `packages/react-app/src`, `BoringAvatars.jsx` & `YourBoringAvatars.jsx` in `packages/react-app/src/views`

💼 Edit your deployment scripts in `packages/hardhat/deploy`

📱 Open http://localhost:3000 to see the app

# Deploy it! 🛰

📡 Edit the defaultNetwork in packages/hardhat/hardhat.config.js, as well as targetNetwork in packages/react-app/src/App.jsx, to your choice of public EVM networks

👩‍🚀 You will want to run yarn account to see if you have a deployer address.

🔐 If you don't have one, run yarn generate to create a mnemonic and save it locally for deploying.

🛰 Use a faucet like faucet.paradigm.xyz to fund your deployer address (run yarn account again to view balances)

🛰 This contract uses VRF so remember to also send some link tokens

🚀 Run yarn deploy to deploy to your public network of choice (😅 wherever you can get ⛽️ gas)

🔬 Inspect the block explorer for the network you deployed to... make sure your contract is there.

# 🚢 Ship it! 🚁

✏️ Edit your frontend App.jsx in packages/react-app/src to change the targetNetwork to wherever you deployed your contract.

📦 Run yarn build to package up your frontend.

💽 Upload your app to surge with yarn surge (you could also yarn s3 or maybe even yarn ipfs?)

😬 Windows users beware! You may have to change the surge code in packages/react-app/package.json to just "surge": "surge ./build",

⚙ If you get a permissions error yarn surge again until you get a unique URL, or customize it in the command line.

🚔 Traffic to your url might break the Infura rate limit, edit your key: constants.js in packages/ract-app/src.

# 📜 Contract Verification

Update the api-key in packages/hardhat/package.json. You can get your key here.

Now you are ready to run the yarn verify --network your_network command to verify your contracts on etherscan 🛰

# 💌 P.S.

🌍 You need an RPC key for testnets and production deployments, create an [Alchemy](https://www.alchemy.com/) account and replace the value of `ALCHEMY_KEY = xxx` in `packages/react-app/src/constants.js` with your new key.

📣 Make sure you update the `InfuraID` before you go to production. Huge thanks to [Infura](https://infura.io/) for our special account that fields 7m req/day!

# Thanks 👏🏻

To https://github.com/PatrickAlphaC for his tutorials on SVG NFTs.

# 🏃💨 Speedrun Ethereum

Register as a builder [here](https://speedrunethereum.com) and start on some of the challenges and build a portfolio.

# 💬 Support Chat

Join the telegram [support chat 💬](https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA) to ask questions and find others building with 🏗 scaffold-eth!

---

🙏 Please check out our [Gitcoin grant](https://gitcoin.co/grants/2851/scaffold-eth) too!

### Automated with Gitpod

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/scaffold-eth/scaffold-eth)
