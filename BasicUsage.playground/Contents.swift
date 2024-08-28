//
//  BasicUsage.playground
//  MetaSerialization
//
//  Copyright 2024 cherrywoods
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
 
 This playground contains a simple example
 of using MetaSerialization
 
 It creates a simple Translator,
 that converts basic Swift objects 
 (String, Int, Array, and Dictionar)
 to a simplified JSON format.
 
 Next, it creates a Serialization instance for that Translator
 and uses it so serialize complex Swift objects.
 
 */

// MARK: - encoding to a simplified JSON format

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
    
    if let array = value as? Array<Meta> {
        
        var json = "[ \n"
        for element in array {
            json += convertToJSON(element) + "\n"
        }
        return json + "]"
        
    }
    
    if let dictionary = value as? Dictionary<String, Meta> {
        
        var json = "{ \n"
        for (key, val) in dictionary {
            json += "\"\(key)\": \(convertToJSON(val))\n"
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
        return String(json.dropFirst().dropLast())
    case "[":
        // [ at the beginning -> array
        // trim [\n and \n]
        json = String( json.dropFirst(2).dropLast(2) )
        var array = [Meta]()
        for element in json.split(separator: "\n") {
            array.append( convertToSwift(String(element)) )
        }
        return array
    case "{":
        // { -> dictionary
        // trim {\n and \n}
        json = String( json.dropFirst(2).dropLast(2) )
        var dictionary = [String: Meta]()
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
// PrimitivesEnumTranslator is a basic implementation.
// You will probably write a own implementation of the Translator protocol.

let translator = PrimitivesEnumTranslator(primitives: [.string, .int])

// and thats basically all of the code that is needed to encode
// arbitrary Swift objects implementing Encodable

let serialization = SimpleSerialization<String>(translator: translator,
                                                encodeFromMeta: convertToJSON,
                                                decodeToMeta: convertToSwift)

// MARK: - Serialization

// Some example objects

struct Shape: Codable {
    
    let numberOfSides: Int
    let sideLength: Int
    
}

let triange1 = Shape(numberOfSides: 3, sideLength: 4)
let triange2 = Shape(numberOfSides: 3, sideLength: 1)
let square: Shape = Shape(numberOfSides: 4, sideLength: 2)
let hexagon: Shape = Shape(numberOfSides: 6, sideLength: 7)

let triangles = [ triangle1, triange2 ]
let dictionary = [ "triangles" : triangles, "squares" : [square], "hexagons" : [hexagon] ]

// MARK: encoding

let encoded = try! serialization.encode(dictionary)

// MARK: decoding

try! serialization.decode(toType: [String:Array[Shape]].self, from: encoded)
