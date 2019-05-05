CS1951L Final Project: Gold Rush

Team Members: 
1) Daniel Kostovetsky (dkostove)
2) Jide Omekam (jomekam)
3) Angela Zhuo (azhuo)


                                    Setting Up

Running the code follows similar practice that we learned to program SmartContracts with the truffle package. 

on two separate terminals,  do the following: 

-- run npm install followed by export PATH=$(npm bin):$PATH
-- Before running the test suite, you must first spin up a private blockchain on your computer with ganache. To do this, open a new terminal tab and run the command ‘ganache-cli.’ 
--Now that you have ganache up and r
--Now that you have ganache up and running, you can run the test suite with by opening up a new terminal and running: ‘truffle test’.

                                     Overview
For our final project, we decided to build a decentralized App (DApp) called Gold Rush. The game itself is similar to Cookie Clicker, except instead of cookies, the objective is to obtain as much Gold as possible. Before you get to mining, you need to acquire land (known as a Lode) and equipment. You then assign some equipment to your Lode. Periodically, your Lode will yield Gold and other resources (e.g. iron, aluminum, uranium). Lodes can be purchased with Gold directly from the Game or from other players. Gold can be purchased with Ether but equipment cannot be bought and sold: it can only be crafted from the resources you mine. The most basic equipment (known as bare hands) are given to players for free while more advanced equipment (earthmover, dredge, quantum matter separator) will need to be earned, but they help the players mine better and faster.
Each Lode (land) contains a finite amount of yields (Gold and resources). The resources are organized into four deposits (Topsoil, Subsoil, Bedrock, and Ancient Alien Ruins). The deeper deposits require more advanced equipment but contain more valuable resources.

                               Functionality
We have four contracts (Gold, Lode, Player, Game) written in solidity 
They have been implemented and tested (positive and negative testing)
ERC20 Negative/Positive Tests
GameAndPlayer Negative/Positive Tests
Gold Negative/Positive Test
Lode Negative/Positive Tests


                                Gold Contract                                
an ERC20 token => allows it to be bought, sold, traded, etc. 
Similar to BearBucks (from CryptoBears)

                                Lode Contract

Similar to an ERC721 token (CryptoBears from CryptoBears), except that each Lode is a separate instance of the contract
Each Lode tracks who owns it, how many yields it has left, what equipment is being used, etc.
Has the power to mint Gold and give it (in addition to other resources) to the owner of the Lode

                                Game Contract
The “master” contract, similar to BearCrowdsale (from CryptoBears)
Sells Gold in exchange for Ether
Sells fresh Lodes in exchange for Gold
Allows players to buy/sell existing lodes for Gold
Keeps a registry of legitimate Lodes and Players in order to prevent impersonation attacks

                                Player Contract
Essentially a user interface: makes it more convenient to interact with the Game and Lodes
Keeps track of Gold, Lodes, resources, and equipment owned
Allows crafting of equipment from resources


                                Challenges
Throughout this project, we ran into several challenges. We initially were not sure which contracts needed to be associated with each other and based our format off of Crytobears. We also had issues trying to make Lode as an ERC-721 token but later decided to change it so that each Lode is a separate instance of the contract. 


                                Takeaways
We learned through this project that
1) test cases are key for catching errors
2) emit messenges are helpful for translating backend logic to UI functionality




