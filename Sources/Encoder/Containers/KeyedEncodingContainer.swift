//
//  KeyedCodingContainer.swift
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
 Manages a EncodingKeyedContainerMeta
 */
open class MetaKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    
    public typealias Key = K
    
    // MARK: properties
    
    /**
     A reference to this containers underlying `EncodingKeyedContainerMeta`
     */
    open var reference: Reference
    
    /**
     The encoder that created this container.
     
     Encoding, creating new containers and creating super encoders is delegated to it.
     */
    open let encoder: MetaEncoder
    
    open let codingPath: [CodingKey]
    
    // MARK: utilities
    
    private var referencedMeta: EncodingKeyedContainerMeta {
        
        get {
            
            return reference.meta as! EncodingKeyedContainerMeta
            
        }
        
        set {
            
            reference.meta = newValue
            
        }
        
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, at codingPath: [CodingKey], encoder: MetaEncoder) {
        
        precondition(reference.meta is EncodingKeyedContainerMeta, "reference.meta needs to conform to EncodingKeyedContainerMeta")
        
        self.reference = reference
        self.codingPath = codingPath
        self.encoder = encoder
        
    }
    
    // MARK: - encode
    
    open func encodeNil(forKey key: Key) throws {
        
        try encode(NilMarker.instance, forKey: key)
        
    }
    
    public func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        
        referencedMeta.put( try encoder.wrap(value, at: key),
                            for: MetaCodingKey(codingKey: key) )
        
    }
    
    // MARK: - nested container
    
    public func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> {
        
        return encoder.container(keyedBy: keyType,
                                 referencing: createElementReference(for: key),
                                 at: codingPath + [key])
        
    }
    
    public func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        return encoder.unkeyedContainer(referencing: createElementReference(for: key),
                                        at: codingPath + [key])
        
    }
    
    // MARK: - super encoder
    
    public func superEncoder() -> Encoder {
        
        return superEncoderImpl(forKey: SpecialCodingKey.super.rawValue)
        
    }
    
    public func superEncoder(forKey key: K) -> Encoder {
        
        return superEncoderImpl(forKey: key)
        
    }
    
    private func superEncoderImpl(forKey key: CodingKey) -> Encoder {
        
        return encoder.encoder(referencing: createElementReference(for: key),
                               at: codingPath + [key])
        
    }
    
    // MARK: - overridable methods
    
    /**
     Create a new reference for the element at the given coding key.
     
     nestedContainer, nestedUnkeyedContainer and superEncoder use this method to create element references.
     */
    open func createElementReference(for key: CodingKey) -> Reference {
        
        let elementRef = KeyedContainerElementReference(referencing: reference, at: MetaCodingKey(codingKey: key))
        return Reference.containerElement( elementRef )
        
    }
    
}
