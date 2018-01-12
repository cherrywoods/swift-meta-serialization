//
//  KeyedCodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 Manages a KeyedContainerMeta
 */
open class MetaKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    
    public typealias Key = K
    
    private(set) open var reference: Reference
    private(set) open var referencedMeta: KeyedContainerMeta {
        get {
            return reference.element as! KeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    open var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    // MARK: - encode
    
    open func encodeNil(forKey key: Key) throws {
        try encode(GenericNil.instance, forKey: key)
    }
    
    open func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        
        // the coding path needs to be extended, because wrap(value) may throw an error
        try reference.coder.stack.append(codingKey: key)
        
        let meta = try (self.reference.coder as! MetaEncoder).wrap(value, typeForErrorDescription: "\(T.self)")
        
        self.referencedMeta[key] = meta
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
    }
    
    // MARK: - nested container
    open func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        let nestedMeta = self.reference.coder.translator.keyedContainerMeta()
        
        self.referencedMeta[key] = nestedMeta
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        return KeyedEncodingContainer(
            MetaKeyedEncodingContainer<NestedKey>(referencing: nestedReference, codingPath: self.codingPath)
        )
        
    }
    
    open func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        let nestedMeta = self.reference.coder.translator.unkeyedContainerMeta()
        
        self.referencedMeta[key] = nestedMeta
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        return MetaUnkeyedEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
    // MARK: - super encoder
    
    open func superEncoder() -> Encoder {
        return superEncoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    open func superEncoder(forKey key: K) -> Encoder {
        return superEncoderImpl(forKey: key)
    }
    
    private func superEncoderImpl(forKey key: CodingKey) -> Encoder {
        
        let referenceToOwnMeta = KeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, at: key)
        
        return ReferencingMetaEncoder(referencing: referenceToOwnMeta)
        
    }
    
}
