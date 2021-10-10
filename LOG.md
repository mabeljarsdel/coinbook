Log
===




JSON Decoding Performance
-------------------------
Currentlly slowness of `JSONDecoder` implementation is one of the major bottleneck of the app.
It takes about 30% load of spike section. Optimizing this would yield largest benefit.

AFAIK, world-fastest JSON decoder is this one.

- https://simdjson.org
- Implemented in C++.
- Able to decode GB/s level. (faster than SSD)
- 4x or more times faster than any other implementation.

There's a wrapper implementation of the lib for Swift.

- https://github.com/michaeleisel/ZippyJSON
- Drop-in replacement of `JSONDecoder`.
- Claims to be 3-5x faster then `JSONDecoder` class.
- Not widely tested.
- Works well so far for this app. 

As its drop-in replacement, it's definitely worth to try.








Slow Start-Up
-------------
App waits about 3-5 seconds on start up.
Here's partial summary of performance log.

    0.0 sec. Initial rendering to UI. (as we render empty UI at launch)

        1633846698.784333 OrderBook3: UI recv: 0 items
        
    1.7 sec until initial welcome message from websocket.
        
        1633846700.485316 NonActorRawChannel: 189 bytes: {"info":"Welcome to the BitMEX Realtime API.","ver
        1633846700.4861689 RawChannel: {"info":"Welcome to the BitMEX Realtime API.","ver (189 bytes)
        1633846700.4863129 BitMEXChannel: recv from raw-chan, start JSON decoding. (189 bytes)
        1633846700.4880152 BitMEXChannel: recv from raw-chan, end JSON decoding.  (189 bytes, 0.0015850067138671875 sec.)
        1633846700.488244 BitMEX: recv from chan

    0.3 sec until initial subscription success message from websocket.

        1633846700.790791 NonActorRawChannel: 123 bytes: {"success":true,"subscribe":"orderBookL2:XBTUSD","
        1633846700.7910352 NonActorRawChannel: 117 bytes: {"success":true,"subscribe":"trade:XBTUSD","reques
        1633846700.7916842 RawChannel: {"success":true,"subscribe":"orderBookL2:XBTUSD"," (123 bytes)
        1633846700.791854 BitMEXChannel: recv from raw-chan, start JSON decoding. (123 bytes)
        1633846700.791798 RawChannel: {"success":true,"subscribe":"trade:XBTUSD","reques (117 bytes)
        1633846700.7930899 BitMEXChannel: recv from raw-chan, end JSON decoding.  (123 bytes, 0.0010650157928466797 sec.)
        1633846700.793293 BitMEX: recv from chan
        1633846700.7932591 BitMEXChannel: recv from raw-chan, start JSON decoding. (117 bytes)
        1633846700.793528 BitMEXChannel: recv from raw-chan, end JSON decoding.  (117 bytes, 5.0902366638183594e-05 sec.)
        1633846700.793617 BitMEX: recv from chan

    1.8 sec until initial trade table snapshot.

        1633846702.634229 NonActorRawChannel: 655 bytes: {"table":"trade","action":"partial","keys":[],"typ
        
    0.9 sec until initial order-book table snapshot.

        1633846703.566835 NonActorRawChannel: 802572 bytes: {"table":"orderBookL2","action":"partial","keys":[
        1633846703.586285 RawChannel: {"table":"orderBookL2","action":"partial","keys":[ (802572 bytes)
        1633846703.586419 BitMEXChannel: recv from raw-chan, start JSON decoding. (802572 bytes)
        1633846703.629848 BitMEXChannel: recv from raw-chan, end JSON decoding.  (802572 bytes, 0.043022990226745605 sec.)
        1633846703.630002 BitMEX: recv from chan
        1633846703.6562781 Core: recv from bitmex
        1633846703.669026 Root: ROOT

    0.1 sec until second rendering to UI. (including decoding)    

        1633846703.6691709 OrderBook3: UI recv: 40 items

It took about 4.7 seconds just to receive initial order-book snapshot data before decoding.
This is all about I/O. Initial snapshot is 800KB. Nothing can be done at client level.
Maybe we can try these things.

- Find out optimal network route. I have no idea how to do this.
- Verify websocket implementation performance. It can slow down things if badly implemented.













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

After refactoring to actor model and testing on iOS 15 devices,
I no longer observe notable spikes or energy inefficiency.
Though overall CPU usage has been increased somewhat, I think now is better.  

For now items with largest relative cost are like this.

    6.17 s   22.9%    0 s                        0x18717620e
    4.92 s   18.3%    1.00 ms                                   OrderBookTableView.render(_:visibleBounds:)
    854.00 ms    3.1%    0 s                       specialized BTXSortedSet.map<A>(_:)
    762.00 ms    2.8%    0 s                       specialized BTXSortedSet.map<A>(_:)
    501.00 ms    1.8%    0 s                       specialized BTXSortedSet.map<A>(_:)

... and so on.
Now rendering is the most contributor, and it's not easily optimizable.
I clsoe this case here.








Burst (Spike) Section Performance
---------------------------------
Here's spike analysis on iOS 14 without actor model.

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

After refactoring to actor model and running on iOS 15, major constribution is like this.

    8.00 ms   26.6%    0 s                              -[UIView(CALayerDelegate) drawLayer:inContext:]
    6.00 ms   20.0%    0 s                                  OrderBookTableView.render(_:visibleBounds:)

Bt the way, as Instruments is malfunction and doesn't show symbols properly.
I need to reinvestigate this later.

