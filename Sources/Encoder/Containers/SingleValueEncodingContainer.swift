//
//  SingleValueEncodingContainer.swift
//  meta-serialization
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
