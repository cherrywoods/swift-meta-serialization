//
//  BasicUsage.playground
//  meta-serialization
//
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Cocoa
import MetaSerialization

/*
 
 This playground contains a verry basic example
 of the usage of MetaSerialization
 
 A simple Translator will be created,
 that converts (certain) swift objects
 to some kind of simple json format.
 
 For that Translator a Representation
 and a Serialization object will be created and used.
 
 */

// MARK: - encoding to a reduced JSON format

func convertToJSON(_ value: Any?) -> String {
    
    // String and Int are the two supported types passed to PrimitivesEnumTranslator
    
    if let string = value as? String {
        
        return "\"\(string)\""
        
    } else if let int = value as? Int {
        
        return "\(int)"
        
    }
    
    // both Arrays and Dictionarys already contain encoded values
    
    // Array and Dictionary always need
    // to be supported when using PrimitivesEnumTranslator
    
    if let array = value as? Array<String> {
        
        var json = "[ \n"
        for element in array {
            json += element + "\n"
        }
        return json + "]"
        
    }
    
    if let dictionary = value as? Dictionary<String, String> {
        
        var json = "{ \n"
        for (key, val) in dictionary {
            json += "\"\(key)\": \(val)\n"
        }
        return json + "}"
        
    }
    
    return ""
    
}

func convertToSwift(_ json: String) -> Any? {
    var json = json
    
    switch json.first! {
    case "\"":
        // " at the beginning -> this is a string
        // remove the two "s
        // ( note that it is realy important to
        // return Strings and not Substrings,
        // because PrimitivesEnumTranslator can't handle Substrings )
        return String(json.dropFirst().dropLast())
    case "[":
        // [ at the beginning -> array
        // trim of [\n and \n]
        json = String( json.dropFirst(2).dropLast(2) )
        var array = [Any]()
        for element in json.split(separator: "\n") {
            array.append( convertToSwift(String(element))! )
        }
        return array
    case "{":
        // { -> dictionary
        // trim {\n and \n}
        json = String( json.dropFirst(2).dropLast(2) )
        var dictionary = [String: Any]()
        for line in json.split(separator: "\n") {
            let keyAndValue = line.split(separator: ":")
            // drop " and "
            let key = String( keyAndValue[0].dropFirst().dropLast() )
            // remove the blank before the values
            let val = convertToSwift(String( keyAndValue[1].dropFirst() ))!
            dictionary[key] = val
        }
        return dictionary
    default:
        // this should be a number
        return Int(json)
    }
    
}

func toJSON(_ value: Any?) -> Any {
    return convertToJSON(value) as Any
}

func toSwift(_ value: Any) -> Any? {
    return convertToSwift(value as! String)
}

// MARK: - using MetaSerialization

// Translators are a key part of MetaSerialization.
// PrimitivesEnumTranslator is a verry simple implementation.
// Usually you will write a own implementation of the Translator protocol.

let translator = PrimitivesEnumTranslator(primitives: [.string, .int],
                                          encode: toJSON,
                                          decode: toSwift)

// and thats basically all of the code that is needed to encode
// arbitrary swift objects implementing Encodable

// MARK: - frontends
// MARK: Serialization

let serialization = SimpleSerialization<String>(translator: translator)

// MARK: Representation

extension String: Representation {
    
    public func provideNewDecoder() throws -> MetaDecoder {
        return try MetaDecoder(translator: translator, raw: self)
    }
    
    public static func provideNewEncoder() -> MetaEncoder {
        return MetaEncoder(translator: translator)
    }
    
}

// MARK: - serialization

// these are just some example instances

struct Shape: Codable {
    
    let numberOfSides: Int
    let sideLength: Int
    
}

let triange = Shape(numberOfSides: 3, sideLength: 4)
let array = [ "three", "four", "six" ]
let dictionary = [ "triangle" : 3, "square" : 4, "hexagon" : 6 ]

// MARK: encoding

// this is how to use a serialization instance
let encodedTriagle = try! serialization.encode(triange)

// this is the way to use Representation
let encodedArray = try! String(encoding: array)

let encodedDictionary = try! serialization.encode(dictionary)

// MARK: decoding

try! serialization.decode(toType: Shape.self, from: encodedTriagle)
try! encodedArray.decode(type: [String].self)
try! encodedDictionary.decode(type: [String:Int].self)

// And that's it.
// 179 lines it is already possible to encode and decode arrays,
// dictionarys and custom Encodable instances
