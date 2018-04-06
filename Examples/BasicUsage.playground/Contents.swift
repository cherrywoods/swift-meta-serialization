//
//  BasicUsage.playground
//  MetaSerialization
//
//  Copyright 2018 cherrywoods
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa
import MetaSerialization

/*
 
 This playground contains a verry basic example
 of the usage of MetaSerialization
 
 A simple Translator will be created,
 that converts (certain) swift objects
 to some kind of simple json format.
 
 For that Translator a Serialization instance will be created and used.
 
 */

// MARK: - encoding to a reduced JSON format

func convertToJSON(_ value: Meta) -> String {
    
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

func convertToSwift(_ json: String) -> Meta {
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
            array.append( convertToSwift(String(element)) )
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
            let val = convertToSwift(String( keyAndValue[1].dropFirst() ))
            dictionary[key] = val
        }
        return dictionary
    default:
        // this should be a number
        return Int(json)!
    }
    
}

func toJSON(_ value: Any?) -> Any {
    return convertToJSON(value as! Meta) as Any
}

func toSwift(_ value: Any) -> Any? {
    return convertToSwift(value as! String)
}

// MARK: - using MetaSerialization

// Translators are a key part of MetaSerialization.
// PrimitivesEnumTranslator is a verry simple implementation.
// Usually you will write a own implementation of the Translator protocol.

let translator = PrimitivesEnumTranslator(primitives: [.string, .int])

// and thats basically all of the code that is needed to encode
// arbitrary swift objects implementing Encodable

let serialization = SimpleSerialization<String>(translator: translator,
                                                encodeFromMeta: convertToJSON,
                                                decodeToMeta: convertToSwift)

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

let encodedTriagle = try! serialization.encode(triange)
let encodedArray = try! serialization.encode(array)
let encodedDictionary = try! serialization.encode(dictionary)

// MARK: decoding

try! serialization.decode(toType: Shape.self, from: encodedTriagle)
try! serialization.decode(toType: [String].self, from: encodedArray)
try! serialization.decode(toType: [String:Int].self, from: encodedDictionary)
