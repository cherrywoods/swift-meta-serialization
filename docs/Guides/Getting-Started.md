# Getting Started
The most simply way to use MetaSerialization is to use `PrimitivesEnumTranslator` and `SimpleSerialization`. There is another quite simple option: using `PrimitivesProtocolTranslator` instead of `PrimitivesEnumTranslator`.

If those types do not furnish your needs, you will most likely have to write your own implementations of `MetaSupplier` (to encode) and `Unwrapper` (to decode).
Read the documentation of those types to find out how to use them.
There are [two example implementations for MetaSerialization](TODO:) that may help you understanding these types.

Both `MetaEncoder` and `MetaDecoder` are optimized to be easily overridable.
