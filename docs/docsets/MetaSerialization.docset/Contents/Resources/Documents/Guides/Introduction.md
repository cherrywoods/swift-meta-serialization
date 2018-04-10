# Introduction
Lets pretend you liked to serialize to JSON and want to write your own library for this (yes, there are all ready frameworks for this and Foundation also contains an implementation, but lets also pretend you want to have your own).

If your write this library, you will somehow have to implement things like this:

* convert `Dictionary<String, Any>` to `{ ... }` in JSON,
* convert `Array<Any>` to `[ ... ]`,
* set quotation marks around Strings,

and much more. But how will you handle any type that someone using your framework created? For example my special car type:
``` swift
class Car: Codable {
    let color: String
    let maxSpeed: Int
    var currentSpeed: Int
    ...
}
```
I would like to store and transmit it using JSON. You can't consider this type in your implementation, because you can't know all these custom types...

Luckyly Swift automatically provides me with implementations for `encode(to:)` to encode and `init(from:)` to decode, because `Car` conforms to `Codable`. These methods work fine and are able to serialize my type in a very format independent way, but those implementations require you to have custom `Decoder` and `Encoder` implementations.

If you now look at the [JSONEncoder.swift file from Foundation](https://github.com/apple/swift/blob/5.0-dont-hardcode-numbers-in-objc-block-sil/stdlib/public/SDK/Foundation/JSONEncoder.swift) you can see, that there is a lot of code that needs to be written to implement a custom `Decoder` or `Encoder`. You may also see, that you might copy very large parts of this file for most serialization formats. In total: There's a lot of overhead.

Now luckly you should not have to copy this code, because this is what MetaSerialization is for:
It is here to save you from copying and provide you a simpler interface instead.

If you already implemented the code above, it should be possible integrate MetaSerialization into your project and provide support for `Codable` types in just two lines of code:
```swift
let translator = PrimitivesEnumTranslator(primitives: .all)
let serialization = SimpleSerialization<Example1Container>(translator: translator, encodeFromMeta: yourEncodingFunction, decodeToMeta: yourDecodingFunction)
```

However, this very limited approach is not the only way to use MetaSerialization.
Read the [Getting Started](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Getting-Started.md) guide the discover the other ways.
