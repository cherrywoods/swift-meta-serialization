# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/cherrywoods/swift-meta-serialization.svg?branch=testing)](https://travis-ci.org/cherrywoods/swift-meta-serialization)

MetaSerialization is a framework to simplify the creation of new serialisation libraries for the swift standard library environment (Encodable, Decodable, Codable, etc.)
It's aim is to let anyone create a serialization library that works with the swift serialization framework by nearly just writing the real serialization code. To archive this goal, it includes a default `Encoder` and `Decoder` implementation that delegate a small part of their work to implementations of `MetaSupplier` / `Unwrapper`, but are furthermore extendible. Most common use cases should however not require overriding eigther `MetaEncoder` or `MetaDecoder`, but should be archivable with a short custom implementation of `MetaSupplier` / `Unwrapper`. In the most extreme form, it is possible to build codable support for an existing framework in [2 lines of code](https://github.com/cherrywoods/swift-meta-serialization/blob/73f067c2c542d4548813d3c8884755dee270ec64/Examples/Example1/Example1.swift#L14-L16).

## Installation
MetaSerialization supports these dependency managers:
 - [CocoaPods](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#cocoapods),
 - [Carthage](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#carthage)
 - [Swift Package Manager](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#swift-package-manager).

## Documentation


## What it does
MetaSerialization provides a layer in between your serialization framework and the swift standard library interface
(mainly Encoder and Decoder) and implements most of the overhead Encoder and Decoder require.

## How it works
MetaSerialization provides implementations for `Encoder` and `Decoder`, `MetaEncoder` and `MetaDecoder`, that rely on a `MetaSupplier` and an `Unwrapper`.

With these helpers, `MetaDecoder` and `MetaEncoder` create a representation of the serialized data in a meta format.

This format is created in a way, that in the end the *meta tree* (as I call the in-between format) will only contain values, that *are natively supported by your framework* or in other words that you can encode directly.

This enables you to serialize any swift class or struct or enum you or anyone else writes, plus any array, dictionary, tuple, Int, String, and so on to an external (I call it raw) representation that only supports, say, Numbers, String and some kind of Dictionarys and Arrays by mainly writing the code to convert a swift Int to your representation of a number, a swift String to your representation of a String, a swift Array of exclusively your supported types (Number, String, Dictionary, Array in this example) to your representation of a *unkeyed container* or Array and a swift Dictionary (of exclusively your supported types) to your representation of a *keyed container* or Dictionary (or Map).

Implementing this still looks like a lot of work and pretty complicated, but this, I guess, is what you would have to do anyway to implement the serialization process.
Concretely, in the previous example about JSON, you would need write this code:
* convert a `KeyedContainerMeta` (you chose the concrete implementation) to this JSON: `{ ... }` (`...` represents other JSON you need create),
* convert a `UnkeyedContainerMeta` (again, you chose which one) to this JSON: `[ ... ]`,
* set quotation marks around Strings and convert your other primitives types.

Codable and MetaSerialization will already have converted any custom types to such *(un)keyed containers* at this point.

The thing about this procedure is that it can be called recursively to encode and decode these *(un)keyed containers* (this is in some manner also the principle the whole `Codable` environment relies on), but this isn't the topic of this frameworks, it's just a general idea for encoding and decoding.

## Installation
Install MetaSerialization via Cartage, CocoaPods or use the swift package manager.
### Carthage
Add the following line to your projects Cartfile:
```ogdl
github "cherrywoods/swift-meta-serialization" ~> 1.0
```
For more information about cartage and it's usage, please consult [carthage's github repository](https://github.com/Carthage/Carthage "https://github.com/Carthage/Carthage").
### CocoaPods
Add the following line to your Podfile:
```ruby
pod 'MetaSerialization', '~> 1.0'
```
For more information about Cocoapods, consult [cocoapods.org](https://cocoapods.org)
### Swift Package Manager
Insert the following code into your Package.swift file, into the dependencies array of your Package.
```swift
.package(url: "https://github.com/cherrywoods/swift-meta-serialization.git", from: "1.0.0"),
```
Please note, that I never tested whether this will work, please open a pull request if it doesn't. Carthage should work.

For more information about the swift package manager, visit [https://swift.org/package-manager/](https://swift.org/package-manager/ "https://swift.org/package-manager/").

## Usage
You can find a example [here](https://github.com/cherrywoods/swift-meta-serialization/blob/master/Examples/BasicUsage.playground/Contents.swift). The example presents a very simple and basic way to use MetaSerialization, that is also the shortest way to use this framework. Clone this repository, if you'd like to play around with it.

[This repository](https://github.com/cherrywoods/meta-serialization-example) contains a complete example implementation for the self invented useless 🚂-serialization format. You may use this example as a blueprint for most other implementations.

Finally [swift-msgpack-serialization](https://github.com/cherrywoods/swift-msgpack-serialization) is a real implementation for the [msgpack serialization format](msgpack.org), that deploys further features of MetaSerialization.

There is also a [fork, here](https://github.com/cherrywoods/MessagePack.swift/tree/master/Codable%20Support), that shows how simple it can be to add `Codable` support to an existing framework with MetaSerialization.

The Wiki tab of this repository also contains some pages about what MetaSerilaization does. Hopefully you will find help there. If not, open an issue.

In the docs/ directory from this repository you can find the swift documentation generated by [jazzy](https://github.com/realm/jazzy).
This documentation is also available online at https://cherrywoods.github.io/swift-meta-serialization/.

## Limitation
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead.

Furthermore you may not do anything in your encoding and decoding code. There are some limitations beyond swifts limitations, when you are using MetaSerialization (or using a framework using MetaSerialization). [Here's a list](https://github.com/cherrywoods/swift-meta-serialization/wiki/Illegal-Encoding-or-Decoding-Behaviours) of code snippets, for which MetaSerialization will give you the "go directly into the prision" card/crash.

## Testing
This project is tested against the tests of JSONEncoder from Foundation.

This applies for version 1, the current release. While this release works fine in general and passes all test that JSONEncoder specifies, it isn't that great to subclass and overwrite. Due to this, there is a new version (2.0) that is currently not release ready, because a lot of added features has not been tested yet. However, 2.0 is also already capable of all JSONEncoder tests. You may clone directly from the master branch to get ther new version.

## Licensing
This framework is licensed at the Apache Version 2.0 License, (nearly) the same license swift is licensed at.

## Help wanted!
 - [ ] Include more tests
 - [ ] Write more documentation, e.g. the complete decoding example process isn't complete.
 - [ ] Provide a simpler way to use MetaSerialization
