# Getting Started
The most simply way to use MetaSerialization is to use `PrimitivesEnumTranslator` and `SimpleSerialization`. There is another quite simple option: using `PrimitivesProtocolTranslator` instead of `PrimitivesEnumTranslator`.

If those types do not match your needs, you will most likely have to write your own implementations of `MetaSupplier` (to encode) and `Unwrapper` (to decode).
Read the documentation of those types to find out how to use them.

## Examples
The MetaSerialization repository itself includes three example implementations in the [Examples folder](https://github.com/cherrywoods/swift-meta-serialization/tree/master/Tests/MetaSerializationTests/Examples) these examples are used for MetaSerialization's tests.

There are two more verbose implementations that demonstrate the use of MetaSerialization at https://github.com/cherrywoods/meta-serialization-examples:
 * [🚂Format](https://github.com/cherrywoods/meta-serialization-examples/tree/master/TrainFormat)
 * [🧞‍Format](https://github.com/cherrywoods/meta-serialization-examples/tree/master/GenieFormat)
