//
//  Representation.swift
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

import Foundation
@testable import MetaSerialization

protocol Example3Representation: Representation {}

extension String: Example3Representation {
    
    public static func provideNewEncoder() -> MetaEncoder {
        
        return Example3Encoder()
        
    }
    
    public func provideNewDecoder() throws -> MetaDecoder {
        
        return MetaDecoder(unwrapper: Example3Translator())
        
    }
    
    public init(meta: Meta) throws {
        
        // convert from an (unnested) array or dictionary to a pure string with markers
        // see README.md for more details
        
        if let string = meta as? String {
            
            self = "*\(string)*"
            
        } else if let array = meta as? [Meta] {
            
            // actually elements should be strings
            
            self = "unkeyed;"
            for element in array {
                self += "*\(element)*,"
            }
            
        } else if let dictionary = meta as? [String : Meta] {
            
            self = "keyed;"
            for (key, value) in dictionary {
                self += "*\(key)*:*\(value)*,"
            }
            
        } else {
            
            preconditionFailure("Somehow a wrong meta made it here!")
            
        }
        
    }
    
    public func convert() throws -> Meta {
        
        if self.starts(with: "*") {
            
            return String( self.dropFirst().dropLast() )
            
        } else if self.starts(with: "unkeyed;") {
            
            var meta = [Meta]()
            
            // this will sufficently split values and komma separators
            let elements = self.dropFirst( "unkeyed;".count ).split(separator: "*")
            
            // now filter out the separators by dropping every secoding element which should be ,
            for index in (elements.startIndex..<elements.endIndex) {
                
                if (index - elements.startIndex) % 2 == 1 {
                    
                    guard elements[index] == "," else {
                        throw Example3.Errors.invalidlyFormatedString(String(elements[index]))
                    }
                    
                    // do not copy to meta, which is dropping
                    
                } else {
                    
                    meta.append(String(elements[index]))
                    
                }
                
            }
            
            return meta
            
        } else if self.starts(with: "keyed;") {
            
            var meta = [String : Meta]()
            
            // this will sufficently split values and komma separators
            let elements = self.dropFirst( "keyed;".count ).split(separator: "*")
            
            // now filter out the separators by dropping every secoding element
            // but check that the element separators are right
            for index in (elements.startIndex..<elements.endIndex) {
                
                switch (index - elements.startIndex) % 4  {
                case 1:
                    // this should be colons
                    guard elements[index] == ":" else {
                        throw Example3.Errors.invalidlyFormatedString(String(elements[index]))
                    }
                    // and drop it / not copy it to meta
                case 3:
                    // this should be kommas
                    guard elements[index] == "," else {
                        throw Example3.Errors.invalidlyFormatedString(String(elements[index]))
                    }
                    // also drop it
                case 0:
                    // here we get the keys, the values are calculatable
                    
                    guard elements.count > index + 2 /*the index value should be found at*/ else {
                        throw Example3.Errors.invalidlyFormatedString(self)
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
            
            throw Example3.Errors.invalidlyFormatedString(self)
            
        }
        
    }
    
}
