# Implementation Overview
MetaSerialization provides a `Decoder` and an `Encoder` implementation.

Those implementations both rely on a storage, that must conform to the `CodingStorage` protocol.
The used `CondingStorage` determines some background properties of both `MetaDecoder` and `MetaEncoder` (the `Decoder` and `Encoder` implementations of MetaSerialization). 
See Coding Storage/README.md for more information about this. Concrete information about `MetaEncoder` and `MetaDecoder` can be found in Decoder/README.md and Encoder/README.md.
This document gives you general information about those implementations.

# Method and Property visibilities.

Both `MetaDecoder` and `MetaEncoder` and also the six decoding and encoding containers (`MetaKeyedEncodingContainer`, etc...) have mostly public and open methods/properties and only a few private ones.

All private methods and properties are utilities that reduce code duplication or provide better structuring.

All methods/properties that are required by an outside protocol (as `Decoder` or `UnkeyedEncodingContainer`) are typically declared public (`encodeNil` is an exception). Public methods always fall back to an open generalization, that, especially in the container implementations, may be ones of another class (`Decoder` or `Encoder` in these cases). However these public methods also perform some type checking or may also contain core functionality (like adding an encoded meta to an underlying container meta in the container implementations), but it should be possible to customize those classes far enough by overriding the open methods.

# Implementational Concepts
## General
### No 1: `CodingStorage`
Both `MetaDecoder` and `MetaEncoder` use a `CodingStorage` that are used to store intermediate objects during the encoding/decoding process.
By default, MetaSerialization uses one the same storage implementation for both, the `Decoder` and `Encoder` implementations.

## Encoder
### No 2: References
`MetaEncoder` needs some write back behavior to it's storage, because Metas may be value types and due to swifts copy-on-write behavior, changes to Metas in encoding containers would not be available to the encoder. This write back is implemented using `Reference`. A reference can either point to the storage or inside a container Meta. 
Decoder does not use references, because the whole Meta tree isn't changed while the decoder is working.

### No 3: `ReferencingStorage`
`ReferencingStorage` is the way `MetaEncoder` provides super encoders. The "super encoders" are intended for encoding `super` but can also be used for other purposes.
MetaSerialization uses the same encoder class for providing super encoders, that, however, uses another kind of storage during initialization, an instance of `ReferencingStorage`.
`ReferencingStorage` uses a second `CodingStorage` to actually store Metas. Additionally, it uses a `Reference` to write back the encoded Metas
