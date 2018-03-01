#  MetaEncoder
MetaEncoder is the `Encoder` implementation of MetaSerialization.

- [ ] TODO: Extend this file to describe all parts of the Encoding process

## Overriding
MetaEncoder has several methods that are overridable, but not all methods are.
The methods required by `Encoder` are however not overridable. You should be able to customize these methods by overriding the overridable methods far enough.
All required methods fall back to those methods at some point. The storage managing part is however not overridable.
