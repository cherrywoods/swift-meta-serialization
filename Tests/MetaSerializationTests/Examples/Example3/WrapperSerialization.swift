//
//  WrapperSerialization.swift
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

struct WrapperSerialization<R>: Serialization where R: Representation {
    
    typealias Raw = R
    
    func encode<E>(_ value: E) throws -> R where E : Encodable {
        
        return try R.init(encoding: value)
        
    }
    
    func decode<D>(toType type: D.Type, from raw: R) throws -> D where D : Decodable {
        
        return try raw.decode(type: type)
        
    }
    
    func provideNewDecoder() -> MetaDecoder {
        preconditionFailure()
    }
    
    func convert(raw: R) throws -> Meta {
        preconditionFailure()
    }
    
    func provideNewEncoder() -> MetaEncoder {
        preconditionFailure()
    }
    
    func convert(meta: Meta) throws -> R {
        preconditionFailure()
    }
    
}
