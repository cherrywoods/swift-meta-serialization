//
//  KeyedDecodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 19.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

// all decoding and encoding classes (formerly structs) manage intrinsically mutable state, because this state is not set yet. That's why they are classes now.

/**
 Manages a KeyedContainerMeta
 */
open class MetaKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    
    public typealias Key = K
    
    private(set) open var reference: Reference
    open var referencedMeta: KeyedContainerMeta {
        get {
            return reference.element as! KeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    open var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    // MARK: - container methods
    
    open var allKeys: [K] {
        // because only this class should access reference, all keys should be K
        return referencedMeta.allKeys() as [K]
    }
    
    open func contains(_ key: K) -> Bool {
        return referencedMeta.contains(key: key)
    }
    
    // MARK: - decoding
    
    open func decodeNil(forKey key: K) throws -> Bool {
        
        // if subscript returns nil, there's no value contained
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "No value for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        return subMeta is NilMetaProtocol
        
    }
    
    open func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        
        // if subscript returns nil, there's no value contained
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "No value for key: \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        // the coding path needs to be extended, because unwrap(meta) may throw an error
        try reference.coder.stack.append(codingKey: key)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        let unwrapped = try (self.reference.coder as! MetaDecoder).unwrap(subMeta, toType: type) as T
        
        return unwrapped
        
    }
    
    // MARK: - nested container
    
    open func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: key)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        // first check whether there's a meta at all for the key
        guard let subMeta = self.referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "No container for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        // check, wheter subMeta is a KeyedContainerMeta
        guard let keyedSubMeta = subMeta as? KeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<NestedKey>.self, context)
        }
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: keyedSubMeta)
        
        return KeyedDecodingContainer(
            MetaKeyedDecodingContainer<NestedKey>(referencing: nestedReference)
        )
        
    }
    
    open func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: key)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        // first check whether there's a meta at all for the key
        guard let subMeta = self.referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "No container for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let unkeyedSubMeta = subMeta as? UnkeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: unkeyedSubMeta)
        
        return MetaUnkeyedDecodingContainer(referencing: nestedReference)
        
    }
    
    // MARK: - super encoder
    
    open func superDecoder() throws -> Decoder {
        return try self.superDecoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    open func superDecoder(forKey key: K) throws -> Decoder {
        return try self.superDecoderImpl(forKey: key)
    }
    
    func superDecoderImpl(forKey key: CodingKey) throws -> Decoder {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        try reference.coder.stack.append(codingKey: key)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        let subMeta = self.referencedMeta[key] ?? NilMeta()
        let referenceToOwnMeta = KeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, at: key)
        let decoder = ReferencingMetaDecoder(referencing: referenceToOwnMeta, meta: subMeta)
        
        return decoder
        
    }
    
}
