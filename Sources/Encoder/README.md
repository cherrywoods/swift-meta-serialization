#  MetaEncoder
MetaEncoder is the `Encoder` implementation of MetaSerialization.

- [ ] TODO: Extend this file to describe all parts of the Encoding process

## Overriding
MetaEncoder has several methods that are overridable, but not all methods are.
The methods required by `Encoder` are however not overridable. You should be able to customize these methods by overriding the overridable methods far enough.
All required methods fall back to those methods at some point. The storage managing part is however not overridable.

## Feature Changelog
### v1.0:
 * In difference to the old version storage can also store a new meta if the last meta is a p.laceholder. This makes requesting a single value container and then encoding a "single value" like an array possible which failed in the old versions. This is the same behavior as JSONEncoder from Foundation shows.
