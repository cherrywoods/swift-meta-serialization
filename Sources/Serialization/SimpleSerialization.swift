//
//  SimpleSerialization.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
