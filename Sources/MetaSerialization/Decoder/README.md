#  MetaDecoder

MetaDecoder is the `Decoder` implementation of MetaSerialization.

MetaDecoder is largely symmetric to MetaEncoder, which is documented in more depth. 
The MetaDecoder documentation is mostly limited to showing the differences to MetaEncoder.

MetaDecoder is somewhat more simple than MetaEncoder, because during decoding the Meta tree is static.
Meta's and the Meta tree are just read.

Therefore, there is no need to implement write back behavior or references. It is possible to copy the Metas for each container.

## Decoding

The decoding process works like the encoding process. The user needs to construct the Meta tree before calling `decode`.

As MetaEncoder, MetaDecoder can be used mulitiple types, but is not suited for parallel decoding.

## Overriding

MetaDecoder has some open methods that are very similar to MetaEncoder's open methods. You can do the same with these methods, as you can with MetaEncoder's methods.

## Feature Change Log
### v2.0:
* No longer decoding from a concrete format in decode
 * Centralized methods for container and further encoder creation.
 * Now using `CodingStorage`
 * Simplified implementation
