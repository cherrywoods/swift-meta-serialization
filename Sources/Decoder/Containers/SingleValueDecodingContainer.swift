//
//  SingleValueDecodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 20.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 Manages all kinds of metas, that represent some kind of single value
 */
open class MetaSingleValueDecodingContainer: SingleValueDecodingContainer {
    
    /**
     This MetaSingleValueDecodingContainer's meta.
     */
    open let meta: Meta
    
    /**
     The decoder that created this container.
     
     Decoding is delegated to it.
     */
    open let decoder: MetaDecoder
    
    open let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(for meta: Meta, at codingPath: [CodingKey], decoder: MetaDecoder) {
        
        self.meta = meta
        self.codingPath = codingPath
        self.decoder = decoder
        
    }
    
    // MARK: decoding
    
    open func decodeNil() -> Bool {
        
        return meta is NilMetaProtocol
        
    }
    
    open func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        // add coding key, so containers,
        // that were requested as single value containers
        // but are not directly supported by the translator
        // can be stored by unwrap.
        
        return try decoder.unwrap(meta, toType: type, for: SpecialCodingKey.decodingThroughSingleValueContainer.rawValue)
        
    }
    
}
