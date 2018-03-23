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
 Provides a simple Serialization class, you pass a translator in initalization.
 SimpleSerialization uses that translator for all objects it serializes.
 */
public class SimpleSerialization<R>: Serialization {
    
    public typealias Raw = R
    
    private let metaSupplier: MetaSupplier
    private let unwrapper: Unwrapper
    
    private let encode: (Meta) throws -> R
    private let decode: (R) throws -> Meta
    
    public init(_ metaSupplier: MetaSupplier, unwrapper: Unwrapper, encodeFromMeta: @escaping (Meta) throws -> R, decodeToMeta: @escaping (R) throws -> Meta) {
        
        self.metaSupplier = metaSupplier
        self.unwrapper = unwrapper
        self.encode = encodeFromMeta
        self.decode = decodeToMeta
        
    }
    
    public func provideNewEncoder() -> MetaEncoder {
        
        // TODO: check for best default with some speed tests
        return MetaEncoder(metaSupplier: metaSupplier, storage: LinearCodingStack())
        
    }
    
    public func provideNewDecoder() -> MetaDecoder {
        
        return MetaDecoder(unwrapper: unwrapper, storage: LinearCodingStack())
        
    }
    
    public func convert(raw: R) throws -> Meta {
        
        return try decode(raw)
        
    }
    
    public func convert(meta: Meta) throws -> R {
        
        return try encode(meta)
        
    }
    
}
