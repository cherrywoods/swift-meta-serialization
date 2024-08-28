//
//  Translator.swift
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

import Foundation
@testable import MetaSerialization

struct Example3Translator: MetaSupplier, Unwrapper {
    
    func wrap<T>(_ value: T, for encoder: MetaEncoder) throws -> Meta? where T : Encodable {
        
        guard !(value is NilMarker) else {
            return nil
        }
        
        // supply Metas for all LosslessStringConvertible types
        // nil also works because NilMarker is already extended in Example2
        guard let description = (value as? LosslessStringConvertible)?.description else {
            return nil
        }
        
        return description
        
    }
    
    // Use the default keyed and unkeyed containers:
    // Arrays of String and Dictionarys of Strings and Strings
    
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
