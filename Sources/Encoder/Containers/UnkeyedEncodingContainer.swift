//
//  UnkeyedEncodingContainer.swift
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
 Manages a UnkeyedContainerMeta
 */
open class MetaUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    // MARK: properties
    
    /**
     A reference to this containers underlying `UnkeyedContainerMeta`
     */
    open var reference: Reference
    
    /**
     The encoder that created this container.
     
     Encoding, creating new containers and creating super encoders is delegated to it.
     */
    open let encoder: MetaEncoder
    
    open let codingPath: [CodingKey]
    
    // MARK: utilities
    
    private var referencedMeta: EncodingUnkeyedContainerMeta {
        
        get {
            
            return reference.meta as! EncodingUnkeyedContainerMeta
            
        }
        
        set {
            
            reference.meta = newValue
            
        }
        
    }
    
    private var lastCodingKey: CodingKey {
        return createCodingKey(for: count)
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, at codingPath: [CodingKey], encoder: MetaEncoder) {
        
        precondition(reference.meta is EncodingUnkeyedContainerMeta, "reference.meta needs to conform to EncodingUnkeyedContainerMeta")
        
        self.reference = reference
        self.codingPath = codingPath
        self.encoder = encoder
        
    }
    
    // MARK: count
    
    open var count: Int {
        
        return referencedMeta.count
        
    }
    
    // MARK: - encode
    
    open func encodeNil() throws {
        
        try encode(GenericNil.instance)
        
    }
    
    public func encode<T: Encodable>(_ value: T) throws {
        
        referencedMeta.insert(element: try encoder.wrap(value, at: lastCodingKey ), at: count )
        
    }
    
    // MARK: - nested container
    
    public func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        
        return encoder.container(keyedBy: keyType,
                                 referencing: createElementReference(for: count),
                                 at: codingPath + [lastCodingKey])
        
    }
    
    public func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        
        return encoder.unkeyedContainer(referencing: createElementReference(for: count),
                                        at: codingPath + [lastCodingKey])
        
    }
    
    // MARK: - super encoder
    
    public func superEncoder() -> Encoder {
        
        return encoder.encoder(referencing: createElementReference(for: count),
                                    at: codingPath + [lastCodingKey])
        
    }
    
    // MARK: - overridable methods
    
    /// create a coding key for the given index
    open func createCodingKey(for index: Int) -> CodingKey {
        
        return IndexCodingKey(intValue: index)!
        
    }
    
    /**
     Create a new reference for the element at the given index.
     
     nestedContainer, nestedUnkeyedContainer and superEncoder use this method to create element references.
     */
    open func createElementReference(for index: Int) -> Reference {
        
        let elementRef = UnkeyedContainerElementReference(referencing: reference, at: index)
        return Reference.containerElement( elementRef )
        
    }
    
}
