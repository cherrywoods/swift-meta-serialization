# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/cherrywoods/swift-meta-serialization.svg?branch=testing)](https://travis-ci.org/cherrywoods/swift-meta-serialization)

MetaSerialization is a framework to simplify the creation of new serialisation libraries for the swift standard library environment (Encodable, Decodable, Codable, etc.)
It's aim is to let anyone create a serialization library that works with the swift serialization framework by nearly just writing the real serialization code.

## What it does
MetaSerialization provides a layer inbetween your serialization framework and the swift standard library interface 
(mainly Encoder and Decoder) and implements most of the overhead Encoder and Decoder require.
### What it does in many words
MetaSerialization provides a MetaEncoder and MetaDecoder, that depend on a so-called Translator. 

MetaDecoder and MetaEncoder create a representation of the serialized data in a meta format. 
This format is created in a way, that in the end the *meta tree* (as I call the in-between format) will only contain values, 
that *are natively supported by your framework* or in other words that you can encode directly. 
This enables you to serialize any swift class or struct or enum you write, 
plus any array, dictionary, tuple, Int, String, and so on to an external (I call it raw) representation that only supports, 
say, Numbers, String and some kind of Dictionarys and Arrays by mainly writing the code to convert a swift Int to your representation of a number, a swift String to your representation of a String, a swift Array of exclusively your supported types (Number, String, Dictionary, Array in this example) to your representation of a *unkeyed container* or Array and  a swift Dictionary (of exclusively your supported types) to your representation of a *keyed container* or Dictionary (or Map).

Ok, this should like a lot of work and pretty complicated, but this, I guess, is what you would have to do anyway to implement the serialization process.

If you liked to serialize to JSON (yes, there are all ready frameworks for this and Foundation also contains an implementation, but lets pretend you want to have your own), for example, you will somehow have to implement things like this:

* convert `Dictionary<String, Any>` to `{ ... }` in JSON,
* convert `Array<Any>` to `[ ... ]`,
* set quotation marks around Strings

and much more. But how will you handle any type that someone using your framework created? For example my special car type
``` swift
class Car: Codable {
    let color: String
    let maxSpeed: Int
    var currentSpeed: Int
    ...
}
```
I would like to store and transmit using JSON. You can' consider this type in your implementation, because you don't even know it.

Luckyly Swift automatically provides me with implementations for `encode(to:)` and `init(from:)`, because `Car` conforms to `Codable`. But those implementations need `Decoder` and `Encoder` implementations. If you look at the [JSONEncoder.swift file](https://github.com/apple/swift/blob/5.0-dont-hardcode-numbers-in-objc-block-sil/stdlib/public/SDK/Foundation/JSONEncoder.swift) you can see, that there is a lot of code that needs to be written to implement a custom `Decoder` or `Encoder`. You may also see, that you might copy verry large parts of this file for most serialization formats. In total: There's a lot of overhead.

Now do you really want to copy this code? It will take you some time to read and understand it and if this implementation changed you would need to have to change your code too (ok if you have just one serialization framework, but already pretty anoying if you have two).

This is what MetaSerialization is for. It is here to TODO: 

## Installation
Install MetaSerialization via Cartage, CocoaPods or swift package manager.
### Carthage
Add the following line to your projects Cartfile:
```ogdl
github "cherrywoods/swift-meta-serialization"
```
For more information about cartage and it's usage, please consult [carthage's github repository](https://github.com/Carthage/Carthage "https://github.com/Carthage/Carthage").
### CocoaPods
Add the following line to your Podfile:
```ruby
pod 'MetaSerialization', '~> 0.1.0'
```
For more information about Cocoapods, consult [cocoapods.org](https://cocoapods.org)
### Swift Package Manager
Insert the following code into your Package.swift file, into the dependencies array of your Package.
```swift
.package(url: "https://github.com/cherrywoods/swift-meta-serialization.git", from: "0.0.4"),
```
Please note, that I never tested whether this will work, please open a pull request if it doesn't. Carthage should work.

For more information about the swift package manager, visit [https://swift.org/package-manager/](https://swift.org/package-manager/ "https://swift.org/package-manager/").

## Usage
You can find a example [here](https://github.com/cherrywoods/swift-meta-serialization/blob/master/Examples/BasicUsage.playground/Contents.swift). The example presents a verry simple and basic way to use MetaSerialization, that is also the shortest way to use this framework. Clone this repository, if you'd like to play around with it.

[This repository](https://github.com/cherrywoods/meta-serialization-example) contains a complete example implementation for a self invented useless serialization format. You may use this example as a blueprint for most other implementations.

Finally [swift-msgpack-serialization](https://github.com/cherrywoods/swift-msgpack-serialization) is a real implementation for the [msgpack serialization format](msgpack.org), that deploys further features of MetaSerialization.

The Wiki tab of this repository also contains some pages about what MetaSerilaization does. You may also find help there. 

In the docs/ directory from this repository you can find the swift documentation generated by [jazzy](https://github.com/realm/jazzy).
This documention is also available online at https://cherrywoods.github.io/swift-meta-serialization/.

## Limitation
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead.

Furthermore you may not do anything in your encoding and decoding code. There are some limitations beyond swifts limitations, when you are using MetaSerialization (or using a framework using MetaSerialization). [Here's a list](https://github.com/cherrywoods/swift-meta-serialization/wiki/Illegal-Encoding-or-Decoding-Behaviours) of code snippets, for which MetaSerialization will give you the "go directly into the prision" card/crash.
## Further documentation
Please consult the [wiki tab in github](https://github.com/cherrywoods/swift-meta-serialization/wiki)
## Testing
This project is tested against the tests of JSONEncoder from Foundation.
Those tests aren't contained on the master branch.
Testing is done on the testing branch. This branch contains code licensed under the Apache License from [the swift standard library](https://github.com/apple/swift).
## Spelling and grammar errors
The project documentation and sourcecode will contain spelling and grammar mistakes. If they obscure the meaning, please open an issue.
## What could be done
 - [ ] Include more tests
 - [ ] Write more documentation, e.g. the complete decoding example process isn't complete.
