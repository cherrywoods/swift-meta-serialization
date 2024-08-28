//
//  ShortExample.swift
//  TestAssertionGuarded
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

import Foundation
import MetaSerialization

// This example is based on Example3

struct ShortExampleSerialization: Serialization {
    
    typealias Raw = String
    
    func provideNewDecoder() -> MetaDecoder {
        
        return MetaDecoder(unwrapper: ShortExampleTranslator())
        
    }
    
    func provideNewEncoder() -> MetaEncoder {
        return MetaEncoder(metaSupplier: ShortExampleTranslator())
    }
    
    func convert(meta: Meta) throws -> String {
        
        // convert from an (unnested) array or dictionary to a pure string with markers
        // see README.md for more details
        
        if let string = meta as? String {
            
            return "*\(string)*"
            
        } else if let array = meta as? [Meta] {
            
            // actually elements should be strings
            
            var result = "unkeyed;"
            for element in array {
                result += "*\(element)*,"
            }
            
            return result
            
        } else if let dictionary = meta as? [String : Meta] {
            
            var result = "keyed;"
            for (key, value) in dictionary {
                result += "*\(key)*:*\(value)*,"
            }
            
            return result
            
        } else {
            
            preconditionFailure("Wrong meta!")
            
        }
        
    }
    
    func convert(raw: String) throws -> Meta {
        
        if raw.starts(with: "*") {
            
            return String( raw.dropFirst().dropLast() )
            
        } else if raw.starts(with: "unkeyed;") {
            
            var meta = [Meta]()
            
            // this will sufficently split values and comma separators
            let elements = raw.dropFirst( "unkeyed;".count ).split(separator: "*")
            
            // now filter out the separators by dropping every secoding element which should be ,
            for index in (elements.startIndex..<elements.endIndex) {
                
                if (index - elements.startIndex) % 2 == 1 {
                    
                    guard elements[index] == "," else {
                        preconditionFailure("String not valid")
                    }
                    
                    // do not copy to meta, which is dropping
                    
                } else {
                    
                    meta.append(String(elements[index]))
                    
                }
                
            }
            
            return meta
            
        } else if raw.starts(with: "keyed;") {
            
            var meta = [String : Meta]()
            
            // this will sufficently split values and komma separators
            let elements = raw.dropFirst( "keyed;".count ).split(separator: "*")
            
            // now filter out the separators by dropping every secoding element
            // but check that the element separators are right
            for index in (elements.startIndex..<elements.endIndex) {
                
                switch (index - elements.startIndex) % 4  {
                case 1:
                    // this should be colons
                    guard elements[index] == ":" else {
                        preconditionFailure("String not valid")
                    }
                // and drop it / not copy it to meta
                case 3:
                    // this should be kommas
                    guard elements[index] == "," else {
                        preconditionFailure("String not valid")
                    }
                // also drop it
                case 0:
                    // here we get the keys, the values are calculatable
                    
                    guard elements.count > index + 2 /* the index value should be found at */ else {
                        preconditionFailure("String not valid")
                    }
                    
                    meta[ String(elements[index]) ] = String(elements[index+2])
                    
                default:
                    // this are the values.
                    // we already handled them, so just ignore
                    break
                }
                
            }
            
            return meta
            
        } else {
            
            preconditionFailure("String not valid")
            
        }
        
    }
    
}

struct ShortExampleTranslator: MetaSupplier, Unwrapper {
    
    func wrap<T>(_ value: T, for encoder: MetaEncoder) throws -> Meta? where T : Encodable {
        
        guard !(value is NilMarker) else {
            return nil
        }
        
        // supply metas for all LosslessStringConvertible types
        // nil also works because NilMarker is already extended in Example2
        guard let description = (value as? LosslessStringConvertible)?.description else {
            return nil
        }
        
        return description
        
    }
    
    // use default keyed and unkeyed containers
    // will be Arrays of String and Dictionarys of Strings and Strings
    
    func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? where T : Decodable {
        
        guard type is LosslessStringConvertible.Type else {
            return nil
        }
        
        guard let string = meta as? String else {
            return nil
        }
        
        return (type as! LosslessStringConvertible.Type).init(string) as! T?
        
    }
    
}
