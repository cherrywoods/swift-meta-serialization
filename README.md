# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/cherrywoods/swift-meta-serialization.svg?branch=master)](https://travis-ci.org/cherrywoods/swift-meta-serialization)

MetaSerialization is a framework to simplify the creation of new serialisation libraries for the Swift standard library environment (`Encodable`, `Decodable`, `Codable`, etc.).
Do you already have code to convert a (nested) Dictionary or Array of basic types (String, Int, etc) to your end format (for example, JSON, YAML, XML)?
Then add support for arbitrary `Codable` Swift types using just one line:
```swift
let serialization = SimpleSerialization<YOUR FORMAT>(encodeFromMeta: YOUR ENCODING FUNCTION, decodeToMeta: YOUR DECONDING FUNCTION)
serialization.encode(anythingCodable)  // done :)
```
A more complete example is contained in the `BasicUsage` playground.
At it's core, MetaSerialization provides a `Encoder` and `Decoder` implementation with several supporting objects moving around it.
The central idea is that these implementations convert Swift objects into a *meta* format (intermediate format).
In the example above, this is the nested Dictionary/Array.
Every part of the process is implemented to be highly customizable, so that MetaSerialization can also support more advanced use cases (for example, different meta formats, formats with anchors).
More advanced examples can be found here:
- TODO.

## Installation
Install MetaSerialization using one of these dependency managers:
 - [Swift Package Manager](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#swift-package-manager).
 - [Carthage](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#carthage)  
 - [CocoaPods](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#cocoapods),

## Documentation
Is available at https://cherrywoods.github.io/swift-meta-serialization/ or in the docs folder of this repository.
These docs also include an [introduction page](https://cherrywoods.github.io/swift-meta-serialization/introduction.html) that outlines the general problem that should be solved by MetaSerialization and a [getting started guide](https://cherrywoods.github.io/swift-meta-serialization/getting-started.html).

You can find a few additional resources in the [wiki tab of this repository](https://github.com/cherrywoods/swift-meta-serialization/wiki). However those guides are mostly about version 1 and might not be helpfull for the current version.

Feel free to open an issue if you have questions about this framework. All suggestions to improve MetaSerialization or it's documentation are welcome (as long as you stick to the [Code of Conduct](https://github.com/cherrywoods/swift-meta-serialization/blob/master/CODE_OF_CONDUCT.md)).

## Limitation
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead.

## Testing
This project is tested against the tests of JSONEncoder from Foundation among other tests specifically designed for MetaSerialization.
All test can be found in the [Tests folder](https://github.com/cherrywoods/swift-meta-serialization/tree/master/Tests).

MetaSerialization uses [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) for testing.

Checkout the source-only branch, if you aren't interested in the contained examples and the tests.

## Versions
### Swift version
| Swift Version | MetaSerialization Version |
| ------------- | --------------------------|
| 5.2           | 2.3                       |
| 5.1           | 2.2                       |
| 4.2           | 2.1.0                     |
| 4.1.2         | 2.0.1                     |
| 4.1           | 2.0                       | 
| 4.0           | 1.0                       |

### 2.3
Version 2.3 adds an optional feature to maintain the insertion order in keyed containers, fixes the tests, and updates the documentation.

### 2.0
Version 2 added a bunch of features, separated encoding and decoding where necessary and provided better overriding options for `Meta(De|En)coder`. However, this resulted in a more closed environment, where not everything is overridable, as it as in version 1.

### 1.0
Version 1 was very similar to Foundations JSONEncoder implementation. Almost everything way declared open.

## Licensing
This framework is licensed at the Apache Version 2.0 License, (nearly) the same license swift is licensed at.
