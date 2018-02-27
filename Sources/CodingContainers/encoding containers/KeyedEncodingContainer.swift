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
    
    private(set) open var reference: Reference
    
    private var referencedMeta: KeyedContainerMeta {
        get {
            return reference.element as! KeyedContainerMeta
        }
        set {
            reference.element = newValue
        }
    }
    
    public var encoder: MetaEncoder {
        
        return reference.coder as! MetaEncoder
        
    }
    
    open let codingPath: [CodingKey]
    
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
        
        self.referencedMeta[key] = try encoder.wrap(value, at: key)
        
    }
    
    // MARK: - nested container
    open func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        let nestedMeta = encoder.translator.keyedContainerMeta()
        
        self.referencedMeta[key] = nestedMeta
        
        let nestedReference = DirectReference(coder: encoder, element: nestedMeta)
        
        // create the path of the new keyed container
        let path = self.codingPath + [key]
        
        return KeyedEncodingContainer(
            MetaKeyedEncodingContainer<NestedKey>(referencing: nestedReference, codingPath: path)
        )
        
    }
    
    open func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        let nestedMeta = encoder.translator.unkeyedContainerMeta()
        
        self.referencedMeta[key] = nestedMeta
        
        let nestedReference = DirectReference(coder: encoder, element: nestedMeta)
        
        // create the path of the new keyed container
        let path = self.codingPath + [key]
        
        return MetaUnkeyedEncodingContainer(referencing: nestedReference, codingPath: path)
        
    }
    
    // MARK: - super encoder
    
    open func superEncoder() -> Encoder {
        return superEncoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    open func superEncoder(forKey key: K) -> Encoder {
        return superEncoderImpl(forKey: key)
    }
    
    private func superEncoderImpl(forKey key: CodingKey) -> Encoder {
        
        let referenceToOwnMeta = KeyedContainerReference(coder: encoder, element: self.referencedMeta, at: key)
        return ReferencingMetaEncoder(referencing: referenceToOwnMeta)
        
    }
    
}
