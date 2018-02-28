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
    
    private(set) open var reference: ReferenceProtocol
    
    private var referencedMeta: KeyedContainerMeta {
        get {
            return reference.element as! KeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    public var decoder: MetaDecoder {
        
        return reference.coder as! MetaDecoder
        
    }
    
    open let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: ReferenceProtocol, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    // MARK: - container methods
    
    open var allKeys: [K] {
        
        return referencedMeta.allKeys() as [K]
        
    }
    
    open func contains(_ key: K) -> Bool {
        
        return referencedMeta.contains(key: key)
        
    }
    
    // MARK: - decoding
    
    open func decodeNil(forKey key: K) throws -> Bool {
        
        // if subscript returns nil, there's no value contained
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "No value for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
            
        }
        
        return subMeta is NilMetaProtocol
        
    }
    
    open func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        
        // if subscript returns nil, there's no value contained
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "No value for key: \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
            
        }
        
        let unwrapped = try decoder.unwrap(subMeta, toType: type, for: key)
        
        return unwrapped
        
    }
    
    // MARK: - nested container
    
    open func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // first check whether there's a meta at all for the key
        guard let subMeta = referencedMeta[key] else {
            
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
        
        let nestedReference = DirectReference(coder: decoder, element: keyedSubMeta)
        let path = codingPath + [key]
        
        return KeyedDecodingContainer( MetaKeyedDecodingContainer<NestedKey>(referencing: nestedReference, codingPath: path) )
        
    }
    
    open func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        
        // first check whether there's a meta at all for the key
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "No container for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let unkeyedSubMeta = subMeta as? UnkeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        let nestedReference = DirectReference(coder: decoder, element: unkeyedSubMeta)
        let path = codingPath + [key]
        
        return MetaUnkeyedDecodingContainer(referencing: nestedReference, codingPath: path)
        
    }
    
    // MARK: - super encoder
    
    open func superDecoder() throws -> Decoder {
        return try self.superDecoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    open func superDecoder(forKey key: K) throws -> Decoder {
        return try self.superDecoderImpl(forKey: key)
    }
    
    func superDecoderImpl(forKey key: CodingKey) throws -> Decoder {
        
        guard let subMeta = referencedMeta[key] else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "No container for key \(key) (\"\(key.stringValue)\") contained.")
            throw DecodingError.keyNotFound(key, context)
        }
        
        let referenceToOwnMeta = KeyedContainerReference(coder: decoder, element: referencedMeta, at: key)
        return ReferencingMetaDecoder(referencing: referenceToOwnMeta, meta: subMeta)
        
        
    }
    
}
