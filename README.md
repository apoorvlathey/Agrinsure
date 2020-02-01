# Agrinsure

Decentralized Crop Insurance against Floods and Droughts
![Agrinsure Homepage](https://i.imgur.com/xioO3iS.jpg)

# Stack Used
1. Solidity
2. Web3.js
3. Chainlink nodes as oracle
4. Honeycomb Marketplace's API
5. Remix IDE for deployment on Ethereum Blockchain

# Inspiration
Farmers often face the problems of crop damage because of natural causes like floods or droughts. The farmers that are insured face difficulties to get their coverage amounts from the insurance companies. Moreover, the insurance companies act as a middleman in all this process.

To remove the middleman and immediately settle insurance claims by the user, I got the inspiration to develop this Decentralized Platform.

# What It Does
Agrinsure is a DApp that gives the power to rightfully claim the insurance back to the farmers.

Users can create their own policy by specifying the type of crop, area and location of their field. They can choose to opt for insurance against Flood or Drought. They pay the required premium fee to the smart contract.

In case of the specified disaster, users can go to the claim page, enter their policy id along with disaster's date and initiate the transaction from the same Ethereum Address with which the policy was created. If the claim is correct, payout equal to the coverage amount is initiated to their address. All this is handled by the smart contract that verifies whether the claim is true or not by analyzing the precipitation levels on that date via API provided through Honeycomb marketplace and the oracle nodes which are hosted by the Chainlink network.

In order to calculate the coverage amount, some parameters have been defined in the contract. According to water levels in the region, 50% or 100% payout is made based on the scale of damage that occurred. Payout and premium fees also vary with the type of crop selected and increase linearly with the area of field.

Users can view the status of the policies along with the time till when it is valid.

# Screenshots
1. Create a new policy by paying the required premium amount.
![](https://i.imgur.com/OtwqCNd.jpg)

2. Pay premium via Metamask's Ethereum Wallet.
![](https://i.imgur.com/CgToKkh.png)

3. Claim insurance in case of tragedies like Flood or Drought.
![](https://i.imgur.com/O7NYAau.jpg)

4. View Details about your Policy
![](https://i.imgur.com/YH96RIu.png)
