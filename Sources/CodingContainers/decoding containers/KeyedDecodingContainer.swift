//
//  KeyedDecodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 19.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

// all decoding and encoding classes (formerly structs) manage intrinsically mutable state, because this state is not set yet. That's why they are classes now.

/**
 Manages a KeyedContainerMeta
 */
open class MetaKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    
    public typealias Key = K
    
    private var reference: Reference
    private var referencedMeta: KeyedContainerMeta {
        get {
            return reference.element as! KeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    public var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    // MARK: - container methods
    
    public var allKeys: [K] {
        // because only this class should access reference, all keys should be K
        return referencedMeta.allKeys() as [K]
    }
    
    public func contains(_ key: K) -> Bool {
        return referencedMeta.contains(key: key)
    }
    
    // MARK: - decoding
    
    public func decodeNil(forKey key: K) throws -> Bool {
        return try self.decode(ValuePresenceIndicator.self, forKey: key).isNil
    }
    
    public func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        
        // if subscript return nil, there's no value contained
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "No value for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        // the coding path needs to be extended, because unwrap(meta) may throw an error
        try reference.coder.stack.append(codingKey: key)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // see MetaKeyedEncodingContainer
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        return try (self.reference.coder as! MetaDecoder).unwrap(subMeta)
        
    }
    
    // MARK: - nested container
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: key)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
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
    
    public func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: key)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
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
    
    public func superDecoder() throws -> Decoder {
        return try self.superDecoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    public func superDecoder(forKey key: K) throws -> Decoder {
        return try self.superDecoderImpl(forKey: key)
    }
    
    func superDecoderImpl(forKey key: CodingKey) throws -> Decoder {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        try reference.coder.stack.append(codingKey: key)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        let subMeta = self.referencedMeta[key] ?? NilMeta()
        let referenceToOwnMeta = KeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, at: key)
        return ReferencingMetaDecoder(referencing: referenceToOwnMeta, meta: subMeta)
        
    }
    
}
