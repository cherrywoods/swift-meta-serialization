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
    
    private(set) open var reference: ReferenceProtocol
    
    public var decoder: MetaDecoder {
        
        return reference.coder as! MetaDecoder
        
    }
    
    open let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: ReferenceProtocol, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    open func decodeNil() -> Bool {
        
        return reference.element is NilMetaProtocol
        
    }
    
    open func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        // add coding key, so containers,
        // that were requested as single value containers
        // but are not directly supported by the translator
        // can be stored by unwrap.
        
        return try decoder.unwrap(reference.element, toType: type, for: SpecialCodingKey.decodingThroughSingleValueContainer.rawValue)
        
    }
    
}
