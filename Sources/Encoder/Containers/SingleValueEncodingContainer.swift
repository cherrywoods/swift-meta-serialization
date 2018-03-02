//
//  SingleValueEncodingContainer.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 Manages all kinds of metas, that represent some kind of single value
 */
open class MetaSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    // MARK: properties
    
    /**
     A reference to this containers underlying `Meta`
     */
    open var reference: Reference
    
    /**
     The encoder that created this container.
     
     Encoding is delegated to it.
     */
    open let encoder: MetaEncoder
    
    open let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, at codingPath: [CodingKey], encoder: MetaEncoder) {
        
        self.reference = reference
        self.codingPath = codingPath
        self.encoder = encoder
        
    }
    
    open func encodeNil() throws {
        
        try self.encode(GenericNil.instance)
        
    }
    
    public func encode<T>(_ value: T) throws where T : Encodable {
        
        // MetaEncoder stores a placeholder when singleValueContainer is called
        // if there is now another meta stored at this path, another meta
        // has already been encoded.
        
        guard !encoder.storage.storesMeta(at: codingPath) else {
            
            preconditionFailure("Tried to encode a second value at a previously used coding path.")
            
        }
        
        reference.meta = try encoder.wrap(value)
        
    }
    
}
