#  Example3 / One Level Format

Container is used to test 
* Writing a custom MetaEncoder implementation
* Using ErrorContainer
* Representation
* not allowing nil values

## Format

Example3 serializes to strings in the form
`"unkeyed;*abc*,*def*,*ghi*,*1*,"`
`"keyed;*key1*:*value1*,*key2*:*value2*,"`
`"*single value*"`
Containers are marked with key words. All single values are strings surrounded by `**`. 
For simplicity, `*` is not allowed in string values.
