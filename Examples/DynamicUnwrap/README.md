#  Example2 / Dynamic meta tree unwrapping example

This exaple format is used to test:
 * dynamic meta tree unwrapping 
 * not supporting nil
 * CodingDictionary
 * not supporting first level non container values

The exaple format consists of an array of Strings and arrays of Strings and arrays of Strings or ...

`["abc", "nine", "fdg", "dada"]` can be seen as unkeyed container or keyed container with keys "abc" and "fdg".

`["ghi", ["abc", "def"], "jkl": ["zyx", "wvu"]]` is another valid example
