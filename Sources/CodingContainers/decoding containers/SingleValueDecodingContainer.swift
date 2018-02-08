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
    
    private(set) open var reference: Reference
    
    open var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    open func decodeNil() -> Bool {
        // we rely on the implementation of or Translator here to handle null values correctly
        return reference.element is NilMetaProtocol
    }
    
    open func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        // add coding key, so containers,
        // that were requested as single value containers
        // but are not directly supported by the translator
        // can be pushed by wrap.
        try self.reference.coder.stack.append(codingKey: SpecialCodingKey.singleValueDecodingContainer.rawValue)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        let unwrapped =  try (self.reference.coder as! MetaDecoder).unwrap(reference.element, toType: type) as T
        
        return unwrapped
        
    }
    
}
