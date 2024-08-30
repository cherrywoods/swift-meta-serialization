# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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

You can find more examples in the [this examples folder](https://github.com/cherrywoods/swift-meta-serialization/tree/main/Tests/MetaSerializationTests/Examples) (used for unit tests).
Additionally, https://github.com/cherrywoods/meta-serialization-examples provides two extended examples.

## Installation
Install MetaSerialization using one of these dependency managers:
 - [Swift Package Manager](https://github.com/cherrywoods/swift-meta-serialization/blob/main/docs/Guides/Installation.md#swift-package-manager)
 - [Carthage](https://github.com/cherrywoods/swift-meta-serialization/blob/main/docs/Guides/Installation.md#carthage)
 - [CocoaPods](https://github.com/cherrywoods/swift-meta-serialization/blob/main/docs/Guides/Installation.md#cocoapods) (latest version 2.3 not available, only 2.1).

## Documentation
Please refer to the docstrings embedded in the source code for API docs. 
Help for installing MetaSerialization and getting started using the framework is available here: https://github.com/cherrywoods/swift-meta-serialization/tree/master/docs/Guides.
These documents will probably leave you with some unanswered questions. Please ask them on the discussions page: https://github.com/cherrywoods/swift-meta-serialization/discussions 
- Not sure whether MetaSerialization can help you? Ask! https://github.com/cherrywoods/swift-meta-serialization/discussions/categories/can-i-use-this-for
- The docs are vague/unclear/do not cover something? https://github.com/cherrywoods/swift-meta-serialization/discussions/categories/q-a
- I would love to see your usecases if you want to share: https://github.com/cherrywoods/swift-meta-serialization/discussions/categories/show-and-tell

Issues and pull requests are also very welcome!
Just make sure you stick to the [Code of Conduct](https://github.com/cherrywoods/swift-meta-serialization/blob/main/CODE_OF_CONDUCT.md).

## Limitations
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead.

## Maintainance Status
I am maintaining this project as a hobby aside my full-time job. I will answer to questions/issues/pull requests within one or two days, but resolving issues may take more time. 

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
