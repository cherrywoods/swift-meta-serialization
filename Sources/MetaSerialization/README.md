# Implementation Overview
As swift requires, MetaSerialization provides a `Decoder` and an `Encoder` implementation.

Those implementations both rely on a storage, that must conform to the protocol `CodingStorage`, that declares the required functionality for such a storage. The actual implementation can be set by the MetaSerialization user and specifies some background properties of both `MetaDecoder` and `MetaEncoder` (the `Decoder` and `Encoder` implementations of MetaSerialization). See Coding Storage/README.md for more information about it. Concrete information about `Meta(De|En)coder` can be found in Decoder/README.md and Encoder/README.md.
This document will be give you general information about those implementations.

# Method and Property visibilities.

Both `MetaDecoder` and `MetaEncoder` and also the six decoding and encoding containers (`MetaKeyedEncodingContainer`, etc...) have mostly public and open methods/properties and only a few private ones.

All private methods and properties are utilities that reduce code duplication or provide better structuring.

All methods/properties that are required by an outside protocol (as `Decoder` or `UnkeyedEncodingContainer`) are typically declared public (`encodeNil` is an exception). Public methods always fall back to an open generalization, that, especially in the container implementations, may be ones of another class (`Decoder` or `Encoder` in these cases). However these public methods also perform some type checking or may also contain core functionality (like adding an encoded meta to an underlying container meta in the container implementations), but it should be possible to customize those classes far enough by overriding the open methods.

## Why isn't everything open
Not all methods/properties are open to give the implementation some shape and provide clear ways for overriding.

In the most cases, it shouldn't be required to override any class from MetaSerialization to use it and get good results from it. Overriding is provided for use cases that need more functionality than provided by default, but still do not require to implement a whole new `Decoder` or `Encoder`. I set this line there, where you need to override one of the public methods, because you need to change some of it's non open code, that I consider specific to the concept of MetaSerializations implementation. Therefor, if you need to change some of this code, I think, you would have actually another core concept and would end up with some code, that would be short, but confusing, because of the two concepts contained in it. I think you should rather write out a new implementation in length, than producing puzzling code. (If you really want to, check out MetaSerialization v1.0 or the v1 branch, those implementations are fully overridable). Please note that a full `Decoder`/`Encoder` implementation does not need to be as long as `JSONEncoder` from Foundation (can be found [here](https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/JSONEncoder.swift)), if you centralize more code. Also note, that you may copy all implementation code from MetaSerialization without restriction, without any need of attribution from my side, because it is licensed under the Unlicense.

If you wan't to do a change that you consider "non concept breaking" that is not possible with the current implementation, please open an issue on github.

# Implementational Concepts
## General
### No 1: `CodingStorage`
Both `MetaDecoder` and `MetaEncoder` use some `CodingStorage`. Having any kind of storage seems required by the documentation of `Decoder` and `Encoder`, although I think it isn't really, I decided to have one (I think one could use some kind of recursive data structure of (de|en)coders and use another (de|en)coder for each coding path, but I decided agains this concept, because I considered it less efficient (although less complex, but I'm no longer so sure there)).

MetaSerialization furthermore uses one the same storage blueprint for both, the `Decoder` and `Encoder` implementations. This is done, because I consider their functionality to be similar enough (nearly equal requirements) to be unified.
## Encoder
### No 2: References
`MetaEncoder` needs some write back behavior to it's storage, because metas may be value types and due to swifts copy-on-write behavior, changes to metas in encoding containers would not be available to the encoder. This write back is implemented using `Reference`. A reference can either point to the storage or inside a container meta. The use of a single reference type for both kinds is further useful to unify similar tasks, that arise in encoding containers. In code, the use of `Reference` does not really look like a write back, rather just like a reference.

Decoder does not use references, because the whole meta tree isn't changed while the decoder is working.
### No 3: `ReferencingStorage`
`ReferencingStorage` is the way `MetaEncoder` provides super encoders. "super encoders" are actually not just suitable for encoding `super`, but this is the name that was given to the methods providing this functionality, and this is the propagated use case (however it has even been "abused" by the standard library implementation itself, some time ago, see https://github.com/apple/swift/blob/swift-4.0-branch-10-10-2017/stdlib/public/core/Codable.swift#L4006). The method that in the end provides such "super encoders" in MetaSerialization is just called `encoder`.

Version 1 followed the path of JSONEncoder here, that uses a subclass of the encoder implementation, that writes back the first element of it's storage to the encoder it was requested as super encoder for, during deinitialization. Version 2 of MetaSerialization does something different. It uses the same encoder implementation with no additional features, that is just passed another kind of storage during initialization, an instance of `ReferencingStorage`.

`ReferencingStorage` uses another `CodingStorage` to actually store metas. It also has a `Reference`. All stores to the base coding path are also written to the reference. This removes the need for another encoder implementation and for write backs during deinitialization. Plus, overriders do not need to provide a new referencing encoder that inherits from their encoder implementation.
