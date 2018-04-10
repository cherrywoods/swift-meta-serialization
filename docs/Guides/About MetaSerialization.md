# What it does
MetaSerialization provides a layer in between your serialization framework and the swift standard library interface
(mainly Encoder and Decoder) and implements most of the overhead Encoder and Decoder require.

## How it works
MetaSerialization provides implementations for `Encoder` and `Decoder`, `MetaEncoder` and `MetaDecoder`, that rely on a `MetaSupplier` and an `Unwrapper`.

With these helpers, `MetaDecoder` and `MetaEncoder` create a representation of the serialized data in a meta format.

This format is created in a way, that in the end the *meta tree* (as I call the in-between format) will only contain values, that *are natively supported by your framework* or in other words that you can encode directly.

This enables you to serialize any swift class or struct or enum you or anyone else writes, plus any array, dictionary, set, Int, String, and so on to an external (I call it raw) representation that only supports, say, Numbers, String and some kind of Dictionaries and Arrays by mainly writing the code to convert a swift Int to your representation of a number, a swift String to your representation of a String, a swift Array of exclusively your supported types (Number, String, Dictionary, Array in this example) to your representation of a *unkeyed container* or Array and a swift Dictionary (of exclusively your supported types) to your representation of a *keyed container* or Dictionary (or Map).

Implementing this still looks like a lot of work and pretty complicated, but this, I guess, is what you would have to do anyway to implement the serialization process.
Concretely, in the example about JSON in the Introduction guide, you would need write this code:
* convert a `KeyedContainerMeta` (you chose the concrete implementation, by default [String : Meta]` is used) to this JSON: `{ ... }` (`...` represents other JSON you need create),
* convert a `UnkeyedContainerMeta` (again, you chose which one, default is `[Meta]`) to this JSON: `[ ... ]`,
* set quotation marks around Strings and convert your other primitives types.

Codable and MetaSerialization will already have converted any custom types to such *(un)keyed containers* at this point.

The thing about this procedure is that it can be called recursively to encode and decode these *(un)keyed containers* (this is in some manner also the principle the whole `Codable` environment relies on), but this isn't the topic of this frameworks, it's just a general idea for encoding and decoding.

## Usage

[This repository](https://github.com/cherrywoods/meta-serialization-example) contains two complete example implementations for two self invented formats. You may use those examples as blueprints for a lot of other implementations.

There is also a [fork, here](https://github.com/cherrywoods/MessagePack.swift/tree/master/Codable%20Support), that shows how simple it can be to add `Codable` support to an existing framework with MetaSerialization.

## Limitation
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead.

Furthermore you may not do anything in your encoding and decoding code. There are some limitations beyond swifts limitations, when you are using MetaSerialization (or using a framework using MetaSerialization). [Here's a list](https://github.com/cherrywoods/swift-meta-serialization/wiki/Illegal-Encoding-or-Decoding-Behaviours) of code snippets, for which MetaSerialization will give you the "go directly into the prision" card/crash.
