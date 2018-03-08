# CodingStorage

CodingStorages are used by both MetaDecoder and MetaEncoder, to store metas that are used during intermediate (de|en)coding steps.

The behavior of a concrete CodingStorage implementation therefor influences the (de|en)coding speed.

There are currently two default implementations contained in MetaSerialization.

All (de|en)coding steps are associated with a coding path, which is an Array of CodingKeys.
A CodingStorage stores a single meta for one coding path.

Metas can be added (`store`), removed (`remove`) and accessed (subscript).

Beyond that implementations need to be able to store placeholders, lock paths, so that the meta stored at this path can not be removed, and fork themselves, which is used to request a CodingStorage that can be used by an independent (de|en)coder at a certain branch of encoding.

## LinearCodingStack
A quick, but less resistant CodingStorage implementation. It uses an array as back end storage and projects the coding paths to their length. This means that it can not differentiate between `[name]` and `[age]`. If such coding paths would be used at the same time, this storage would mess up the encoding process by not allowing a second meta to be stored, or even returning a false meta.

However, because the length of a path can be requested in constant time, this implementation should be in general quicker that CodingDictionary.

fork creates a new LinearCodingStack.

## CodingDictionary
This implementation uses a Dictionary as back end storage. Because arrays of coding keys are not hashable by default, the coding paths are converted to strings in the form "/.../..." (Due to this, store access has complexity O(n), if the coding path has n elements).

This storage is able to store metas for different coding branches. Because of this, fork returns self.

## Feature Change Log
### v2.0:
 * Introduction
