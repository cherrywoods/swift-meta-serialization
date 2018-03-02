//
//  SingleValueDecodingContainer.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
        
        // decode the meta stored at decoders codingPath
        return try decoder.unwrap(toType: type)
        
    }
    
}
