//
//  SingleValueEncodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 17.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 Manages all kinds of metas, that represent some kind of single value
 */
open class MetaSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    private(set) open var reference: Reference
    
    open let codingPath: [CodingKey]
    
    public var encoder: MetaEncoder {
        
        return reference.coder as! MetaEncoder
        
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    open func encodeNil() throws {
        
        try self.encode(GenericNil.instance)
        
    }
    
    open func encode<T>(_ value: T) throws where T : Encodable {
        
        // MetaEncoder stores a placeholder when singleValueContainer is called
        // if there is now another meta stored at this path, another meta
        // has already been encoded.
        
        guard !encoder.storage.isMetaStored(at: codingPath) else {
            
            preconditionFailure("Tried to encode a second value at a previously used coding path.")
            
        }
        
        self.reference.element = try encoder.wrap(value, at: SpecialCodingKey.singleValueContainer.rawValue)
        
    }
    
}
