# Rentrancy attack
A reentrancy vulnerability occurs when a contract modifies its global state after an external call. To make BearCrowdsale vulnerable, I created a contract variable ('excess') to track the change that should be returned to the caller (instead of using a local variable). When buyCryptoBear is called, the change is calculated, added to 'excess', returned to the buyer via '.value.call()', and then 'excess' is reset to zero. If, upon receiving the change, the buyer immediately calls buyCryptoBear again, before 'excess' is reset, he will be paid his previous change again for free.

This is exactly what ReentrancyExploit does. It starts the attack by calling buyCryptoBear. It receives its change via a payable fallback function, which in turn calls buyCryptoBear again. (To make this work, since the change is only 1 Wei, I needed to remove the condition in buyCryptoBear that reverts if insufficient funds are sent - this causes one of the CrowdsaleNegativeTests to fail.) This recursion repeats several times (doing it too much would drain all of BearCrowdsale's funds, leading to a revert), siphoning money from BearCrowdsale.

# Design strategy
I carefully followed the comments of each method, making sure that every part of the specification was implemented. I liberally used 'require' to prevent exploits and pass the negative tests. I installed a Solidity linter that warned me about potential mistakes and security issues (for instance, it detected when I intentionally added a vulnerability to buyCryptoBear).

# Bugs
None that I'm aware of - all tests passed.

#Extra credit
None.