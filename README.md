# Workshop: Making a Honeycomb Request

## Before installation

- Sign up to the [Honeycomb marketplace](https://honeycomb.marketplace) to access the job listings

- Install [npm](https://www.npmjs.com/get-npm)

- Install truffle globally using:

`npm install -g truffle`

- Install the Metamask add-on to your browser and create a wallet.
Note down the mnemonics.
Fund it with [Ropsten ETH](https://faucet.metamask.io/) and [Ropsten LINK](https://ropsten.chain.link/).

- Create an [Infura](https://infura.io/) account, get an endpoint URL for the Ropsten testnet and note it down.

- (Optional) Install [Visual Studio Code](https://code.visualstudio.com/)

## Installation

- Clone this repo

- Install the dependencies:

`npm install`

- Create the file that you are going to enter your Infura credentials:

`cp wallet.json.example wallet.json`

- Open the newly created `wallet.json` file and enter the mnemonics and the endpoint URL you have noted down earlier, similar to `wallet.json.example`.

- Deploy the contract (Ropsten LINK will be transferred from your wallet to the contract automatically during deployment)

`npm run deploy-ropsten`

- Run the test script

`npm run test-ropsten`