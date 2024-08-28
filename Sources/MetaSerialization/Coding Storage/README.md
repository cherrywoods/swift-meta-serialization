# CodingStorage

CodingStorages are used by both MetaDecoder and MetaEncoder to storeMmetas that are used during intermediate (de|en)coding step (encoding attributes, elements of an Array or Dictrionary, s...)

The behavior of a concrete CodingStorage implementation therefor influences the (de|en)coding speed.

All (de|en)coding steps are associated with a coding path, which is an Array of CodingKeys.
A CodingStorage stores a single Meta for one coding path.

Metas can be added (`store`), removed (`remove`) and accessed (subscript).

Beyond that, implementations need to be able to store placeholders, lock paths, so that the meta stored at this path can not be removed, and fork themselves, which is used to request a CodingStorage that can be used by an independent (de|en)coder at a certain branch of encoding.

## LinearCodingStack
A quick, but less robust CodingStorage implementation. It uses an array as backend storage and projects the coding paths to their length. This means that it can not differentiate between `[name]` and `[age]`. If such coding paths would be used at the same time, this storage would mess up the encoding process by not allowing a second meta to be stored, or even returning a false meta.
Therefore, this CondingStorage requires a strictly sequential encoding/deconding workflow.
