#  MetaDecoder

MetaDecoder is the `Decoder` implementation of MetaSerialization.

MetaDecoder is pretty symmetric to MetaEncoder, which is documented in more extend. The MetaDecoder documentation is mostly limited to showing the differences to MetaEncoder.

MetaDecoder is a bit simpler than MetaEncoder, because during decoding the meta tree is static.
Meta's and the meta tree are just read.

Therefor there is no need to implement write back behavior or references. It is possible to copy the metas for each container.

```
+----------------------------------------------------------+
|                       MetaDecoder                        |
+----------------------------------------------------------+
| * userInfo: [CodingUserInfoKey : Any]                    |
| * codingPath: [CodingKey]                                |
| * unwrapper: Unwrapper                                   |
| * storage: CodingStorage                                 |
+----------------------------------------------------------+
| + init(at: [CodingKey] = [],                             |
|        with: [CodingUserInfoKey : Any] = [:],            |
|        unwrapper: Unwrapper,                             |
|        storage: CodingStorage)                           |
| * unwrap<D>(_: Meta? = nil,                              |
|             toType: D.Type                               |
|             for: CodingKey? = nil)                       |
|             -> D                                         |
|             where D: Decodable                           |
| + container<Key>(keyedBy: Key.Type,                      |
|                  for: Meta,                              |
|                  at: [CodingKey],                        |
|                  -> KeyedDecodingContainer               |
|                  where Key: CodingKey                    |
| * decodingContainer<Key>(keyedBy: Key.Type,              |
|                          for: Meta,                      |
|                          at: [CodingKey],                |
|                          -> KeyedDecodingContainer       |
|                          where Key: CodingKey            |
| + unkeyedContainer(for: Meta,                            |
|                    at: [CodingKey],                      |
|                    -> UnkeyedDecodingContainer           |
| * unkeyedDecodingContainer(for: Meta,                    |
|                            at: [CodingKey],              |
|                            -> UnkeyedDecodingContainer   |
| * singleValueContainer(for: Meta,                        |
|                        at: [CodingKey])                  |
|                        -> SingleValueDecodingContainer   |
| * decoder(for: Meta,                                     |
|           at: [CodingKey])                               |
|           -> Decoder                                     |
| * decoderImplementation(storage: CodingStorage,          |
|                         at: [CodingKey])                 |
|                         -> Decoder                       |
+----------------------------------------------------------+
| + container<Key>(keyedBy: Key.Type)                      |
|                  -> KeyedDecodingContainer               |
|                  where Key: CodingKey                    |
| + unkeyedContainer() -> UnkeyedDecodingContainer         |
| + singleValueContainer() -> SingleValueDecodingContainer |
+----------------------------------------------------------+
| + decode<D>(type: D.Type, from: Meta)                    |
|            -> D                                          |
|            where D: Decodable                            |
+----------------------------------------------------------+
(*: open, +: public)
```

## Decoding

The decoding process works like the encoding process. The user needs to construct the meta tree before calling `decode`.

As MetaEncoder, MetaDecoder can be used mulitiple types, but is not suited for parallel decoding.

## Overriding

MetaDecoder has some open methods that are very similar to MetaEncoder's open methods. You can do the same with these methods, as you can with MetaEncoder's methods.

## Feature Change Log
### v2.0:
* No longer decoding from a concrete format in decode
 * Centralized methods for container and further encoder creation.
 * Now using `CodingStorage`
 * Simplified implementation
