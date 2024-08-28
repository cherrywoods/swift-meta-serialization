#  MetaEncoder
MetaEncoder is the `Encoder` implementation of MetaSerialization.

## Encoding

The encoding process starts with calling `encode` on a MetaEncoder (not on the value that should be encoded itself!), after the MetaEncoder has been initialized with a `MetaSupplier` implementation.  The MetaEncoder then calls `wrap`, which calls `metaSupplier.wrap`. If this returns a value (not nil), wrap returns this meta. If it returned nil, wrap calls `encode(to:)` on the value passed to it. Before this, it stores a placeholder at the current coding path. It also checks that value does not implement `DirectlyEncodable` (String, Bool, Float, Int, etc, see below). Calling `encode(to:)` on value may lead to a call of one of the container methods of the encoder (`container(keyedBy:)`, `unkeyedContainer` or `singleValueContainer`). Following this, potentially `encode` or `encodeNil` are called on the returned container. These method again call encoders `wrap`: the cycle restarts. At some point, an encoding entity will have no further values to encode. At this point, the coding storage contains Metas for all entities visited up to this point. This "Meta tree" is then "collapsed": Metas are removed from the storage again by wrap and the encode methods in the various containers add each Meta to their referenced Meta container (or eventually back to the storage too). After the call stack has been unwinded back to the first call of `encode` on the encoder, the Meta returned by `wrap` is returned.

A single MetaEncoder can be used multiple times if the first encoding process has finished (if `encode` has returned). It's storage is then cleaned up again, and - as long as the meta supplier has no state - the encoder will be in the same state as if it had been initialized freshly. It is also possible to call `encoder.encode` during encoding (e.g. inside a implementation of `Encodable`s `encode` method).

MetaEncoder is not thread safe or suited for parallel encoding.

## Overriding
MetaEncoder has several methods that are overridable, but not all methods are.
The methods required by `Encoder` are not overridable.
You should be able to customize these methods far enough by overriding the overridable methods.
All required methods fall back to those methods at some point. The storage managing part is also not overridable.

The following methods can be overwritten:
 * `encodingContainer(keyedBy:, referencing:, at:)`: This methods creates a new `KeyedEncodingContainer`. It is called by `container(keyedBy:)` and also by the `nestedContainer` methods of MetaSerialization's default encoding container implementations. You can therefore use this method to override the `KeyedEncodingContainerProtocol` implementation MetaEncoder should use.
 * `unkeyedEncodingContainer(referencing:, at:)`: This method is the equivalent to `container(keyedBy:, referencing:, at:, createNewContainer:)` for unkeyed containers.
 * `singleValueContainer(referencing:, at:)`: This method creates a new `SingleValueEncodingContainer`. It is only used by `singleValueContainer()`.
 * `encoder(referencing:, at:)`: Creates a new encoder. This method is used by the default encoding container implementations to create super encoders. You may use this method to override the implementation the default implementations of `KeyedEncodingContainerProtocol` and `UnkeyedEncodingContainer` use as a super encoder.
 * `encoderImplementation(storage:, at:)`: This is the delegate method `encoder` uses. Override this method to use your subclass for, for example, super encoders.
 * `wrap(, at:)`: The core encoding code and the core functionality of MetaSerialization is contained in this method. `wrap` requests Metas from metaSupplier in this method and calls `encode(to:)`, if translator returns nil. `wrap` accesses the storage and the coding path. If you override this method, make sure to include a guard for `DirectlyEncodable` types after asking the `MetaSupplier` because these types will often cause endless loops, if translator does not support them (MetaSerialization publicly extends String, Bool, Int, Float, Int8, etc. to conform to `DirectlyEncodable`). 

## Feature Change Log
### v2.0:
 * No longer encoding to a concrete format in encode
 * Centralized methods for container and further encoder creation.
 * Now using `CodingStorage`
 * Simplified implementation
### v1.0:
 * In difference to the old version storage can also store a new meta if the last meta is a placeholder. This makes requesting a single value container and then encoding a "single value" like an array possible which failed in the old versions. This is the same behavior as JSONEncoder from Foundation shows.
