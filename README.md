CoinBook
========
Hoon H., 2021.



Manually Implemented Actors
---------------------------
You'll see that many of objects are implemented in same pattern.
With serial GCDQ, `queue/dispatch` functions, and runs all commands and reports in the GCDQ.
This is a sort of manually implemented actor model.
Very close resemblence of Swift Actors introduced in Swift 5.5.
The biggest difference is lack of async/await, 
therefore we cannot describe program in imperative way.
Instead, everythig has to be described in event-based model. 



Memory Limit
------------
This app currently defines no limit. 
If server pushes too much data, it potentially can fill up small mobile device local memory quickly.
NO consideration for such situation.



Speed Optimizations
-------------------
There are many room for optimizations.
Currently, JSON decoding is one of the major bottleneck.
Swift's default JSON decoder is well known to be slow. 
Specially written decoder is required to solve this.
It can't be done quickly, therefore I do not cover this.
These are current major bottlenecks.
- JSON decoding.
- Price formatting.
- BTree operation. (this needs module-level inlining for better performance)
BTree may be slow due to lack of inlining over different modules.
Further optimization would requires moving source code into same module.
That is painful to maintain, therefore I do not cover it here.
It can be different in production.



UI
--
Order/trade quantity from BitMEX does not contain fractional numbers.
Therefore I follow BitMEX formatting (no fraction).



Known Issues
------------
- None of `JJLISO8601DateFormatter` or `ISO8601DateFormatter` support fractional part of RFC3339 date-time expression.
  No idea why it doesn't work.
- Fill ratio bar graphics glitch. Sometimes it draws wrong length of bars.
