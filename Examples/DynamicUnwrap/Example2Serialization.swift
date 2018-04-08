//
//  Example2Serialization.swift
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

struct Example2Serialization: Serialization {
    
    typealias Raw = Example2Meta
    
    // MARK: decoding
    
    func provideNewDecoder() -> MetaDecoder {
        
        return MetaDecoder(unwrapper: Example2.translator, storage: CodingDictionary())
        
    }
    
    func convert(raw: Example2Meta) throws -> Meta {
        
        return raw
        
    }
    
    // MARK: encoding
    
    func provideNewEncoder() -> MetaEncoder {
        return MetaEncoder(metaSupplier: Example2.translator, storage: CodingDictionary())
    }
    
    func convert(meta: Meta) throws -> Example2Meta {
        
        guard meta is Example2EncodingContainerMeta else {
            throw Errors.notAllowedFirstLevelNonContainer
        }
        
        return _convert(meta: meta)
        
    }
    
    private func _convert(meta: Meta) -> Example2Meta {
        
        if let container = meta as? Example2EncodingContainerMeta {
            
            return .array( container.array.map( _convert ) )
            
        } else {
            
            // this are wrapped strings
            return meta as! Example2Meta
            
        }
        
    }
    
    enum Errors: Error {
        case notAllowedFirstLevelNonContainer
    }
    
}
