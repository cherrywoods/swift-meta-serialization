//
//  SingleValueDecodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 20.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 Manages all kinds of metas, that represent some kind of single value
 */
open class MetaSingleValueDecodingContainer: SingleValueDecodingContainer {
    
    private var reference: Reference
    
    public var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    public func decodeNil() -> Bool {
        // we rely on the implementation of or Translator here to handle null values correctly
        return reference.element is NilMetaProtocol
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        return try (self.reference.coder as! MetaDecoder).unwrap(self.reference.element)
        
    }
    
}
