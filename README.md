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





Speed Performance
-------------------
There are many room for optimizations.

- JSON decoding.
- Price formatting.
- BTree operation.

Currently, JSON decoding is one of the major bottleneck.
Swift's default JSON decoder is well known to be slow. 
BTW, any properly written JSON decoders easily outperform Swift Codable by 3x-10x.
https://itnext.io/swift-json-performance-ce9438632b02
Therefore this cost can be reduced.

B-Tree code has been inlined to provide "fully specialized generics" for best performance.
Though this is bad for long term maintenance, I don't have other options for now.
I don't know a better algorithm than B-Tree.

IMO there are more room for Rust/C++ based implementations for better performance.

- Avoid copy-on-write (persistency) support.
- No need for mandatory automatic/atomic reference counting.
- More control over memory layout. More CPU/cache-friendliness.

If I have to deal with everything on client, last resort would be implementing 
processing algorithms in Rust/C++ and just feed the final result to Swift side.

Although I'm not sure on cost-effectiveness of it,
writing such in-app backend will be very interesting.

- Rust `serde` is known to be very fast & convenient JSON parser.
- Rust `std::collections` already have (ephemeral) B-Tree implementations.
- Rust `im-rs` is a B-Tree implementation. (with both atomic/non-atomic reference counting)








Burst (Spike) Section Performance
---------------------------------
```
32.00 ms   39.5%    0 s          _dispatch_worker_thread2  0x4babc5
27.00 ms   33.3%    0 s                     dispatch thunk of JSONDecoder.decode<A>(_:from:)
26.00 ms   32.0%    0 s          Main Thread  0x4baad7
13.00 ms   16.0%    0 s                     BitMEX.OrderBook.applyOrderTableNaively(_:_:)
4.00 ms    4.9%    0 s                               specialized BTXMap.subscript.setter
3.00 ms    3.7%    0 s                               specialized BTXSortedSet.remove(_:)
2.00 ms    2.4%    0 s                               specialized BTXMap.subscript.setter
2.00 ms    2.4%    0 s                               specialized BTXSortedSet.remove(_:)
1.00 ms    1.2%    0 s                               specialized BTXSortedSet.remove(_:)
1.00 ms    1.2%    0 s                               specialized BTXMap.subscript.setter
```

- As I decribed, I do not cover JSON decoding performance here.
- `BTX-` types are B-Tree implementations.

BTW, burst sections are fundamentally due to too much backpressure from server.
This is difficult to deal with because,

- I do not have control on amount of server-push.
- Missing message means loss of integrity of whole dataset.

It seems the point of the problem is **burst amount of data** rather than algorithms.
But we have no control over the amount or shape of server feed.





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
