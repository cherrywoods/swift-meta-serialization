#  MetaEncoder
MetaEncoder is the `Encoder` implementation of MetaSerialization.

```
+----------------------------------------------------------+
|                       MetaEncoder                        |
+----------------------------------------------------------+
| * userInfo: [CodingUserInfoKey : Any]                    |
| * codingPath: [CodingKey]                                |
| * metaSupplier: MetaSupplier                             |
| * storage: CodingStorage                                 |
+----------------------------------------------------------+
| + init(at: [CodingKey] = [],                             |
|        with: [CodingUserInfoKey : Any] = [:],            |
|        metaSupplier: MetaSupplier,                       |
|        storage: CodingStorage)                           |
| * wrap<E>(_: E,                                          |
|           at: CodingKey? = nil)                          |
|           -> Meta                                        |
|           where E: Encodable                             |
| + container<Key>(keyedBy: Key.Type,                      |
|                  referencing: Reference,                 |
|                  at: [CodingKey],                        |
|                  createNewContainer: Bool = true)        |
|                  -> KeyedEncodingContainer               |
|                  where Key: CodingKey                    |
| * encodingContainer<Key>(keyedBy: Key.Type,              |
|                          referencing: Reference,         |
|                          at: [CodingKey])                |
|                          -> KeyedEncodingContainer       |
|                          where Key: CodingKey            |
| + unkeyedContainer(referencing: Reference,               |
|                    at: [CodingKey],                      |
|                    createNewContainer: Bool = true)      |
|                    -> UnkeyedEncodingContainer           |
| * unkeyedEncodingContainer(referencing: Reference        |
|                            at: [CodingKey])              |
|                            -> UnkeyedEncodingContainer   |
| * singleValueContainer(referencing: Reference,           |
|                        at: [CodingKey])                  |
|                        -> SingleValueEncodingContainer   |
| * encoder(referencing: Reference,                        |
|           at: [CodingKey])                               |
|           -> Encoder                                     |
| * encoderImplementation(storage: CodingStorage,          |
|                         at: [CodingKey])                 |
|                         -> Encoder                       |
+----------------------------------------------------------+
| + container<Key>(keyedBy: Key.Type)                      |
|                  -> KeyedEncodingContainer               |
|                  where Key: CodingKey                    |
| + unkeyedContainer() -> UnkeyedEncodingContainer         |
| + singleValueContainer() -> SingleValueEncodingContainer |
+----------------------------------------------------------+
| + encode<E>(_: E)                                        |
|             -> Meta                                      |
|             where E: Encodable                           |
+----------------------------------------------------------+
(*: open, +: public)
```

## Encoding

An encoding process ideally starts with the call of `encode` on a MetaEncoder (not on the value that should be encoded itself!), after the MetaEncoder has been initialized with a `MetaSupplier` implementation.  This will lead to a call of `wrap`. Wrap will call `metaSupplier.wrap` and if it returned a value (not nil), wrap will return this meta. If nil was returned, wrap will call `encode(to:)` on the value passed to it. Before this it will store a placeholder at that path. It will also check, that value does not implement `DirectlyEncodable` (String, Bool, Float, Int, etc, do, see below). The call of `encode(to:)` on value may lead to a call of one of the container methods of the encoder (`container(keyedBy:)`, `unkeyedContainer` or `singleValueContainer`). Following up to this maybe `encode` or `encodeNil` are called on the returned container. These method will again call encoders `wrap`, and the cycle restarts. At some point an encoding entity will have no further values to encode. At this point the coding storage contains metas for all the entities visited up to this point. This "meta tree" will then be "collapsed", e.g. metas will be removed from the storage again by wrap and the encode method in the various containers will add this meta to their referenced meta container (or eventually back to the storage too). After the call stack has been unwinded back to the call of `encode` on the encoder, the meta returned by `wrap` will be returned.

A MetaEncoder can be used multiple times, if the first encoding process has finished (if `encode` has returned). It's storage will be cleaned up again, and as long as the meta supplier has no state, the encoder will be in the same state, as if it has been freshly initialized. It is also possible to call `encoder.encode` during encoding (e.g. inside a implementation of `Encodable`s `encode` method).

MetaEncoder is itself not thread safe or suited for parallel encoding.

## Overriding
MetaEncoder has several methods that are overridable, but not all methods are.
The methods required by `Encoder` are not overridable.
You should be able to customize these methods far enough by overriding the overridable methods.
All required methods fall back to those methods at some point. The storage managing part is also not overridable.

The following methods can be overwritten:
 * `encodingContainer(keyedBy:, referencing:, at:)`: This methods creates a new `KeyedEncodingContainer`. It is called by `container(keyedBy:)` and also by the `nestedContainer` methods of MetaSerialization's default encoding container implementations. You can therefor use this method to override the `KeyedEncodingContainerProtocol` implementation MetaEncoder should use.
 * `unkeyedEncodingContainer(referencing:, at:)`: This method is the equivalent to `container(keyedBy:, referencing:, at:, createNewContainer:)` for unkeyed containers.
 * `singleValueContainer(referencing:, at:)`: This method creates a new `SingleValueEncodingContainer`. It is only used by `singleValueContainer()`.
 * `encoder(referencing:, at:)`: Creates a new encoder. This method is used by the default encoding container implementations to create super encoders. You may use this method to override the implementation the default implementations of `KeyedEncodingContainerProtocol` and `UnkeyedEncodingContainer` should use as super encoder.
 * `encoderImplementation(storage:, at:)`: This is the delegate method `encoder` uses. Override this method to use your subclass for e.g. super encoders.
 * `wrap(, at:)`: The core encoding code and the core functionality of MetaSerialization is contained in this method. `wrap` requests metas from metaSupplier in this method and calls `encode(to:)`, if translator returns nil. `wrap` accesses the storage and the coding path. If you're not fine with the concept of `CodingStorage` or facing a problem, that can not be solved by a different implementation of `CodingStorage`, you may have to override this method. If you need to override this method, however, make sure to include a guard for `DirectlyEncodable` types after asking the `MetaSupplier`, because these types will typically cause endless loops, if translator does not support them (MetaSerialization publicly extends String, Bool, Int, Float, Int8, etc. to conform to `DirectlyEncodable`). This code looks like this in the default implementation:
 ```swift
 guard !(value is DirectlyEncodable) else {

     let context = EncodingError.Context(codingPath: codingPath, debugDescription: "DirectlyEncodable value \(String(describing: value)) was not accepted by the Translator implementation.")
     throw EncodingError.invalidValue(value, context)

 }
 ```

## Feature Change Log
### v2.0:
 * No longer encoding to a concrete format in encode
 * Centralized methods for container and further encoder creation.
 * Now using `CodingStorage`
 * Simplified implementation
### v1.0:
 * In difference to the old version storage can also store a new meta if the last meta is a placeholder. This makes requesting a single value container and then encoding a "single value" like an array possible which failed in the old versions. This is the same behavior as JSONEncoder from Foundation shows.
