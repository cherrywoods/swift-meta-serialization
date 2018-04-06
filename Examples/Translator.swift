//
//  Dynamic.swift
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

struct Example2Translator: MetaSupplier, Unwrapper {
    
    // this format does not support nil values.
    
    // MARK: - MetaSupplier
    
    func wrap<T: Encodable>(_ value: T, for encoder: MetaEncoder) throws -> Meta? {
        
        // supply metas for Strings, Doubles, Int, all LosslessStringConvertible types
        if value is LosslessStringConvertible {
            // String is extended to conform to Example2Meta
            return (value as! LosslessStringConvertible).description
        }
        
        return nil
        
    }
    
    func keyedContainerMeta() -> EncodingKeyedContainerMeta {
        
        return Example2EncodingKeyedContainerMeta()
        
    }
    
    func unkeyedContainerMeta() -> EncodingUnkeyedContainerMeta {
        
        return Example2EncodingUnkeyedContainerMeta()
        
    }
    
    // MARK: - Unwrapper
    
    func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? where T : Decodable {
        
        guard type is LosslessStringConvertible.Type && meta is String else {
            return nil
        }
        
        return (type as! LosslessStringConvertible.Type).init(meta as! String) as! T?
        
    }
    
    // MARK: dynamic unwrapping
    
    func unwrap(meta: Meta, toType: DecodingKeyedContainerMeta.Protocol, for decoder: MetaDecoder) throws -> DecodingKeyedContainerMeta? {
        
        guard let array = meta as? [Example2Meta] else {
            return nil
        }
        
        return Example2DecodingKeyedContainerMeta(array: array)
        
    }
    
    func unwrap(meta: Meta, toType: DecodingUnkeyedContainerMeta.Protocol, for decoder: MetaDecoder) throws -> DecodingUnkeyedContainerMeta? {
        
        guard let array = meta as? [Example2Meta] else {
            return nil
        }
        
        return Example2DecodingUnkeyedContainerMeta(array: array)
        
    }
    
}
