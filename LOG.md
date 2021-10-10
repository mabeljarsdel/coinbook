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


