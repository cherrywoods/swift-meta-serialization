//
//  BasicUsage.playground
//  MetaSerialization
//
//  Copyright 2018-2024 cherrywoods
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
 of using MetaSerialization to serialize Swift objects
 into a simplified JSON format.

 The fundamental idea is to use MetaSerialization to
 transform Swift objects into a tree of nested Dictionaries
 and Arrays. 
 Subsequently, this playground converts this tree into a 
 JSON string.
 
 To achieve this, it first creates a basic Translator object
 that converts Strings, Ints, Arrays, and Dictionaries
 to a simplified JSON format.
 Next, it creates a Serialization instance for this Translator
 and uses it so serialize more complex Swift objects.

 */


/**
 Transform a Array or Dictionary of Strings, Ints, and further nested
 Arrays and Dictionaries (type: Meta) into a JSON string.
 */
func convertToJSON(_ value: Meta) -> String {
    
    // String and Int are two fundamental data types that 
    // we support directly in this example.
    // In a real-world application, you would also add Double,
    // Int8, and other fundamental data types here.
    
    if let string = value as? String {
        
        return "\"\(string)\""
        
    } else if let int = value as? Int {
        
        return "\(int)"
        
    }
    
    // Nested "containers": Array and Dictionary.
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

/**
 The other way around: JSON string to nested Array or Dictionary
 of Strings and Ints.
 */
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
        // this should be an integer
        return Int(json)!
    }
    
}

func toJSON(_ value: Any?) -> Any {
    return convertToJSON(value as! Meta) as Any
}

func toSwift(_ value: Any) -> Any? {
    return convertToSwift(value as! String)
}

// Now: use MetaSerialization to support more complex Swift types.
let serialization = SimpleSerialization<String>(
    encodeFromMeta: convertToJSON,
    decodeToMeta: convertToSwift
)
// That's all it takes!

// Now let's try it out!

struct Shape: Codable {
    
    let numberOfSides: Int
    let sideLength: Int
    
}

struct ShapeWorld: Codable {

    let triangles: [Shape]
    let squares: [Shape]
    let other: [Shape]

}

let triange1 = Shape(numberOfSides: 3, sideLength: 4)
let triange2 = Shape(numberOfSides: 3, sideLength: 1)
let square: Shape = Shape(numberOfSides: 4, sideLength: 2)
let hexagon: Shape = Shape(numberOfSides: 6, sideLength: 7)

let world = ShapeWorld(triangles: [triange1, triange2], squares: [square], other: [hexagon])

// To JSON!
let encoded = try! serialization.encode(world)

// Back to Swift.
try! serialization.decode(toType: ShapeWorld.self, from: encoded)
