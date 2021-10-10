CoinBook
========
Hoon H., 2021.


Clean Actor Model Architecture
------------------------------
This app demonstrates how to construct clean architecture with actor model.
Components are implemented as actors (or pseudo actors for UIKit components).
Therefore all of their implementations are isolated by default.
Components communicates only with defined interfaces.
For actor model, datastructures of messages are the interfaces.




Rendering 
---------
- Maintain source BitMEX data in in-app BitMEX client.
- Reduce the source BitMEX data into minimal app state.
- Produce "rendition" data from the app state according to context.
- Pass the rendition to UI. With some throttling. We don't need >60Hz rendering.
- UI performs diff-based rendering. 





Memory Limit
------------
This app currently defines no limit. 
If server pushes too much data, it potentially can fill up small mobile device local memory quickly.
NO consideration for such situation.
IMO, the only way to deal with this kind of backpressure would be 
abandon accumulated state and starting over.



UI
--
Order/trade quantity from BitMEX does not contain fractional numbers.
Therefore I follow BitMEX formatting (no fraction).





Known Issues
------------
- None of `JJLISO8601DateFormatter` or `ISO8601DateFormatter` support fractional part of RFC3339 date-time expression.
  No idea why it doesn't work.
- Fill ratio bar graphics glitch. Sometimes it draws wrong length of bars.
  No idea why it does. I guess wrong handling of how `UICollectionView` works.
  I'll implement custom layout/rendering without `UICollectionView`.
- Nearly no error handling. 




License
-------
This code is licensed under "MIT License".
Copyright(C) Hoon H., Eonil 2021.
