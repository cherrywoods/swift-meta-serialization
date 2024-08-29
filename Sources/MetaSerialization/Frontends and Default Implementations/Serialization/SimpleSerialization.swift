//
//  SimpleSerialization.swift
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

/**
 A simple serialization interface based on a translator.
 */
public class SimpleSerialization<R>: Serialization {
    
    public typealias Raw = R
    
    private let translator: MetaSupplier&Unwrapper
    
    private let encode: (Meta) throws -> R
    private let decode: (R) throws -> Meta
    
    public init(translator: MetaSupplier&Unwrapper = PrimitivesEnumTranslator(), encodeFromMeta: @escaping (Meta) throws -> R, decodeToMeta: @escaping (R) throws -> Meta) {
        
        self.translator = translator
        self.encode = encodeFromMeta
        self.decode = decodeToMeta
        
    }
    
    public func provideNewEncoder() -> MetaEncoder {
        
        return MetaEncoder(metaSupplier: translator, storage: LinearCodingStack())
        
    }
    
    public func provideNewDecoder() -> MetaDecoder {
        
        return MetaDecoder(unwrapper: translator, storage: LinearCodingStack())
        
    }
    
    public func convert(raw: R) throws -> Meta {
        
        return try decode(raw)
        
    }
    
    public func convert(meta: Meta) throws -> R {
        
        return try encode(meta)
        
    }
    
}
