//
//  SingleValueEncodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 17.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 Manages all kinds of metas, that represent some kind of single value
 */
open class MetaSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    private(set) open var reference: Reference
    
    open var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    open func encodeNil() throws {
        try self.encode(GenericNil.instance)
    }
    
    open func encode<T>(_ value: T) throws where T : Encodable {
        
        // if the referenced element is a PlacholderMeta,
        // there was no value encoded in this single value container
        // (MetaEncoder inserts this kind of meta in it's singleValueContainer method)
        // otherwise there's already a real meta and someone already encoded at the correspondig coding path
        // that's basically the same as requesting two containers from encoder (and therefor not allowed)
        // note that no custom Translator can use PlaceholderMeta -
        // for other purposes than this one or any purpose - because it is declared project-private/internal 
        guard self.reference.element is PlaceholderMeta else {
            preconditionFailure("Tried to encode a second value at the same coding path: \(codingPath)")
        }
        
        self.reference.element = try (self.reference.coder as! MetaEncoder).wrap(value, typeForErrorDescription: "\(T.self)")
        
    }
    
}
