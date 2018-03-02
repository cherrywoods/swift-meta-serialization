# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/cherrywoods/swift-meta-serialization.svg?branch=testing)](https://travis-ci.org/cherrywoods/swift-meta-serialization)

MetaSerialization is a framework to simplify the creation of new serialisation libraries for the swift standard library environment (Encodable, Decodable, Codable, etc.)
It's aim is to let anyone create a serialization library that works with the swift serialization framework by nearly just writing the real serialization code.

## Introduction
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

Luckyly Swift automatically provides me with implementations for `encode(to:)` to encode and `init(from:)` to decode, because `Car` conforms to `Codable`. But those implementations need `Decoder` and `Encoder` implementations.

If you now look at the [JSONEncoder.swift file from Foundation](https://github.com/apple/swift/blob/5.0-dont-hardcode-numbers-in-objc-block-sil/stdlib/public/SDK/Foundation/JSONEncoder.swift) you can see, that there is a lot of code that needs to be written to implement a custom `Decoder` or `Encoder`. You may also see, that you might copy very large parts of this file for most serialization formats. In total: There's a lot of overhead.

Now do you really want to copy this code? It will take you some time to read and understand it and if this implementation changed you would need to have to change your code too (ok if you have just one serialization framework, but already pretty anoying if you have two) (the implementation is indeed changed from time to time).

This is what MetaSerialization is for. It is here to save you from copying that code and provide you a simpler interface instead.

It already is not too complicated to use MetaSerialization, but certainly it can still be easier. If you have any idea about this, please comment the issue that already exists for this, open your own issue or pull request (would be super cool 👍), or write an email to cherrywoods@posteo.de.

## What it does
MetaSerialization provides a layer in between your serialization framework and the swift standard library interface
(mainly Encoder and Decoder) and implements most of the overhead Encoder and Decoder require.

## How it works
MetaSerialization provides a MetaEncoder and MetaDecoder, that depend on a so-called Translator.

MetaDecoder and MetaEncoder create a representation of the serialized data in a meta format.

This format is created in a way, that in the end the *meta tree* (as I call the in-between format) will only contain values, that *are natively supported by your framework* or in other words that you can encode directly.

This enables you to serialize any swift class or struct or enum you or anyone else writes, plus any array, dictionary, tuple, Int, String, and so on to an external (I call it raw) representation that only supports, say, Numbers, String and some kind of Dictionarys and Arrays by mainly writing the code to convert a swift Int to your representation of a number, a swift String to your representation of a String, a swift Array of exclusively your supported types (Number, String, Dictionary, Array in this example) to your representation of a *unkeyed container* or Array and a swift Dictionary (of exclusively your supported types) to your representation of a *keyed container* or Dictionary (or Map).

Ok, this should like a lot of work and pretty complicated, but this, I guess, is what you would have to do anyway to implement the serialization process.
In the previous example about JSON, this code be this:

* convert a `KeyedContainerMeta` (you chose the concrete implementation) to this JSON: `{ ... }` (... represents other JSON you create),
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

## Licensing
This project's code could be seen in part as derivate work of JSONEncoder from Foundation, licensed under the Apache v2 license.
Because I'm no layer I can say if realy is a such. Due to this, the Apache license file is included in this repository.

This should only apply for version 1 and before. Version 2 should not be seen a derivate.

## Testing
This project is tested against the tests of JSONEncoder from Foundation.

Those tests aren't contained on the master branch.
Testing is done on the testing branch. This branch contains code licensed under the Apache License from [the swift standard library](https://github.com/apple/swift).

## Spelling and grammar errors
The project documentation and source code will contain spelling and grammar mistakes. If they obscure the meaning, please open an issue.

## What could be done
 - [ ] Include more tests
 - [ ] Write more documentation, e.g. the complete decoding example process isn't complete.
 - [ ] Provide a simpler way to use MetaSerialization
