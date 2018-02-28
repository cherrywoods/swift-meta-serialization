//
//  KeyedCodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 Manages a KeyedContainerMeta
 */
open class MetaKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    
    public typealias Key = K
    
    // MARK: properties
    
    // TODO: doc
    open var reference: Reference
    
    open let encoder: MetaEncoder
    
    open let codingPath: [CodingKey]
    
    // MARK: utilities
    
    private var referencedMeta: KeyedContainerMeta {
        
        get {
            
            return reference.meta as! KeyedContainerMeta
            
        }
        
        set {
            
            reference.meta = newValue
            
        }
        
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, at codingPath: [CodingKey], encoder: MetaEncoder) {
        
        precondition(reference.meta is KeyedContainerMeta, "reference.meta needs to conform to KeyedContainerMeta")
        
        self.reference = reference
        self.codingPath = codingPath
        self.encoder = encoder
        
    }
    
    // MARK: - encode
    
    open func encodeNil(forKey key: Key) throws {
        
        try encode(GenericNil.instance, forKey: key)
        
    }
    
    public func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        
        self.referencedMeta[key] = try encoder.wrap(value, at: key)
        
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
        
        return encoder.superEncoder(referencing: createElementReference(for: key),
                                    at: codingPath + [key])
        
    }
    
    // MARK: - overridable methods
    
    /**
     Create a new reference for the element at the given coding key.
     
     nestedContainer, nestedUnkeyedContainer and superEncoder use this method to create element references.
     */
    open func createElementReference(for key: CodingKey) -> Reference {
        
        let elementRef = KeyedContainerElementReference(referencing: reference, at: key)
        return Reference.containerElement( elementRef )
        
    }
    
}
