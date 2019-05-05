CS1951L Final Project: Gold Rush

Team Members: 
1) Daniel Kostovetsky (dkostove)
2) Jide Omekam (jomekam)
3) Angela Zhuo (azhuo)


                                    Setting Up

Our code can be run in the same way as CryptoBears:

-- Make sure truffle and ganache are installed
-- Make two terminal tabs; in each, move into the Gold Rush directory and run 'export PATH=$(npm bin):$PATH'
-- In one tab, run 'ganache-cli -l 8000000' (the argument '-l 8000000' is necessary because otherwise the test suite may run out of gas)
-- In the other tab, run our test suite with ‘truffle test’
-- Note that there are random elements in our app, so the test suite may fail with some very low probability; if this happens, just run the test suite again

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
Throughout this project, we ran into several challenges. We initially were not sure which contracts needed to be associated with each other and based our format off of Crytobears. We also had issues trying to make Lode an ERC-721 token and later decided to change it so that each Lode is a separate instance of the contract. 


                                Takeaways
We learned through this project that
1) test cases are key for catching errors
2) Solidity is full of idiosyncrasies, and one must proceed with extreme caution to avoid bugs, especially since there is a lot of money at stake and many shady Russians trying to steal it




