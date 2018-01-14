# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

meta-serialization is a framework to simplify writing new serialisation libraries for the swift standard library environment (Encodable, Decodable, etc.)
It's aim is to let anyone create a serialization library that works with the swift serialization framework by nearly just writing the real serialization code.

This framework is **untested**!
Any help is welcome.

## What it does
meta-serialization provides a layer inbetween your serialization framework and the swift standard library interface 
(mainly Encoder and Decoder) and implements most of the overhead Encoder and Decoder require.
### What it does in many words
meta-serialization provides a MetaEncoder and MetaDecoder, that depend on a so-called Translator. 

MetaDecoder and MetaEncoder create a representation of the serialized data in a meta format. 
This format is created in a way, that in the end the *meta tree* (as I call the in-between format) will only contain values, 
that *are natively supported by your framework* or in other words that you can encode directly. 
This enables you to serialize any swift class or struct or enum you write, 
plus any array, dictionary, tuple, Int, String, and so on to an external (I call it raw) representation that only supports, 
say, Numbers, String and some kind of Dictionarys and Arrays by mainly writing the code to convert a swift Int to your representation of a number, a swift String to your representation of a String, a swift Array of exclusively your supported types (Number, String, Dictionary, Array in this example) to your representation of a *unkeyed container* or Array and  a swift Dictionary (of exclusively your supported types) to your representation of a *keyed container* or Dictionary (or Map).

## Installation
Currently only carthage is supported (swift package manager is only half-way supported).
I can not guarante, that cartage will work out, It builds on my computer and all schemes are set public, but I never tried installing it somewere else. I did not manage to add full swift-package-manager support or cocoapods support.
### Carthage
Add the following line to your projects Cartfile:
```ogdl
github "cherrywoods/swift-meta-serialization"
```
For more information about cartage and it's usage, please consult [carthage's github repository](https://github.com/Carthage/Carthage "https://github.com/Carthage/Carthage").
### Swift Package Manager (iOS only)
You may use the swift package manager, but only for the iOS framework.
The other three targets aren't supported because refering to [the swift package manager repository](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#targets) "It is an error if the paths of two targets overlap (unless resolved with exclude)" (If I missunderstood that part please open a pull request).
So, if you need the macOS, tvOS or watchOS target, you may not (simply) use the swift package manager, but the code for all the targets is pretty much the same (there is a little additional code for macOS, but these code only includes a String wrapping Meta For Float80).
However, insert the following code into your Package.swift file, into the dependencies array of your Package.
```swift
.package(url: "https://github.com/cherrywoods/swift-meta-serialization.git", from: "0.0.4"),
```
For more information about the swift package manager, visit [https://swift.org/package-manager/](https://swift.org/package-manager/ "https://swift.org/package-manager/").

## Usage
There are multiple ways to use this framework.
A verry simple way is this one:
```swift
import MetaSerialization

var primitives = Set<PrimitivesEnumTranslator.Primitive>()
primitives.insert(.string) /*this says, that we can only serialize Strings. */

/*
If we tried to serialize any value that had for example an Int property serialization would fail.
Adding all cases from the Primitives enum will enable us to serialize nearly any value.
*/

let translator = PrimitivesEnumTranslator(primitives: primitives,
                                          encode: /* your encoding closure */,
                                          decode: /* your decoding closure */)

/*
 The encoding closures get Any? as parameter,
 but you can be sure that the value is non nil in our example
 (but you may allow nil values, by adding .nil to your primitives)
 and one of your primitives (in this case String),
 an Array<Any?> or a Dictionary<String, Any?>,
 where the Any? parameter is again eigther a String, Array<Any?>,
 Dictionary<String, Any?> and so on.
 The decoding closure may only return one of that values.
*/

/*
 You need to provide a Raw type to SimpleSerialization, in this case we use Data.
 This type need to be the same you take in decode and return in encode.
*/
let serialization = SimpleSerialization<Data>(translator: translator)

// now you might just call
let encoded = try! serialization.encode( /*some object*/ )

// or:
let decoded = try! serialization.decode(type: /*some type*/, from: /*your raw object, some Data in this example*/)
```
## Limitation
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead. 
## Further documentation
Please consult the documentation tab in github
## Spelling and grammar errors
The project documentation and sourcecode will contain spelling and grammar errors. If they obscure the meaning, please tell me about it.
