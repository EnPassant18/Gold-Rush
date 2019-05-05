CS1951L Final Project: Gold Rush
Group Members: 
Daniel Kostovetsky (dkostove)
Jide Omekam (jomekam)
Angela Zhuo (azhuo)


                                    Setting Up

Running the code follows similar practice that we learned to program SmartContracts with the truffle package. 

on two separate terminals,  do the following: 

-- run npm install followed by export PATH=$(npm bin):$PATH
-- Before running the test suite, you must first spin up a private blockchain on your computer with ganache. To do this, open a new terminal tab and run the command ‘ganache-cli.’ 
--Now that you have ganache up and r
--Now that you have ganache up and running, you can run the test suite with by opening up a new terminal and running: ‘truffle test’.
                                     Overview
Decentralized App (DApp)
GoldRush is a game similar to Cookie Clicker, except instead of cookies, the objective is to obtain as much Gold as possible
Gold and Lode are ERC20 tokens, so they have “value”

                                    Mechanics
In order to start mining, you need to acquire land (known as a Lode) and equipment
You then assign some equipment to your Lode
Periodically, your Lode will yield Gold and other resources (e.g. iron, aluminum, uranium)
Lodes can be purchased with Gold directly from the Game or from other players
Gold can be purchased with Ether
Equipment cannot be bought and sold: it can only be crafted from the resources you mine
You receive the most basic equipment (known as bare hands) for free
More advanced equipment (earthmover, dredge, quantum matter separator) mine better and faster
Deposits
Each Lode contains a finite amount of yields (Gold and resources)
The resources are organized into four deposits
The deeper deposits require more advanced equipment but contain more valuable resources

                               Functionality
We have six contracts written in solidity
They have been implemented and tested (positive and negative testing)
ERC20 Negative/Positive Tests
GameAndPlayer Negative/Positive Tests
Gold Negative/Positive Test
Lode Negative/Positive Tests

                            Design Decisions
Code consists of four contracts: Gold, Lode, Player, Game
Gold
Simply an ERC20 token => allows it to be bought, sold, traded, etc.
Similar to BearBucks (from CryptoBears)

                                Lode

Similar to an ERC721 token (CryptoBears from CryptoBears), except that each Lode is a separate instance of the contract
Each Lode tracks who owns it, how many yields it has left, what equipment is being used, etc.
Has the power to mint Gold and give it (in addition to other resources) to the owner of the Lode
                                  Game
The “master” contract, similar to BearCrowdsale (from CryptoBears)
Sells Gold in exchange for Ether
Sells fresh Lodes in exchange for Gold
Allows players to buy/sell existing lodes for Gold
Keeps a registry of legitimate Lodes and Players in order to prevent impersonation attacks

                                Player
Essentially a user interface: makes it more convenient to interact with the Game and Lodes
Keeps track of Gold, Lodes, resources, and equipment owned
Allows crafting of equipment from resources


                              Why Blockchain?

In Cookie Clicker: You can’t trade, buy or sell the cookies you’ve worked hard to collect
Boring: no intrinsic value
You can also break the game by using an auto-clicking tool, or just calling Game.RuinTheFun() from your browser JS console
Boring: no scarcity

                                In Gold Rush

Gold costs Ether, and each Lode only yields slightly more Gold than was used to purchase it, so the supply of Gold is limited
Gold is an ERC20, so it has liquidity and value
Lodes can also be bought and sold, so they also have value
Intrinsic value + scarcity (real money at stake) make the game more interesting

                                Future Roadmaps
For our future steps, we plan on implementing a UI that is indicative of emits that we could add.
