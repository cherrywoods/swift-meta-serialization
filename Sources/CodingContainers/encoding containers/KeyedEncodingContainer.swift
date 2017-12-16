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
    
    typealias Key = K
    
    private var reference: Reference
    private var referencedMeta: KeyedContainerMeta {
        get {
            return reference.element as! KeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    // MARK: - encode
    
    func encodeNil(forKey key: Key) throws {
        try encode(GenericNil.instance, forKey: key)
    }
    
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        
        // the coding path needs to be extended, because wrap(value) may throw an error
        try reference.coder.stack.append(codingKey: key)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should acutally never happen
                // in one case, if wrap does not pop the added container again, wrap already throwed an error and this code will not be executed
                // in the other case, if wrap added no container, the same applies.
                // but I think it is better to crash the programm with a reason, than crash it without one using try!
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        let meta = try (self.reference.coder as! MetaEncoder).wrap(value)
        
        self.referencedMeta[key] = meta
        
    }
    
    // MARK: - nested container
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
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
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        let nestedMeta = self.reference.coder.translator.unkeyedContainerMeta()
        
        self.referencedMeta[key] = nestedMeta
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        return MetaUnkeyedEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
    // MARK: - super encoder
    
    func superEncoder() -> Encoder {
        return superEncoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return superEncoderImpl(forKey: key)
    }
    
    private func superEncoderImpl(forKey key: CodingKey) -> Encoder {
        
        let referenceToOwnMeta = KeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, at: key)
        
        return ReferencingMetaEncoder(referencing: referenceToOwnMeta)
        
    }
    
}
