CoinBook
========

Code for CoinBook.



Manually Implemented Actors
---------------------------
You'll see that many of objects are implemented in same pattern.
With serial GCDQ, `queue/dispatch` functions, and runs all commands and reports in the GCDQ.
This is a sort of manually implemented actor model.
Very close resemblence of Swift Actors introduced in Swift 5.5.
The biggest difference is lack of async/await, 
therefore we cannot describe program in imperative way.
Instead, everythig has to be described in event-based model. 
