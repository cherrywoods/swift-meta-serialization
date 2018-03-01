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
    
    /**
     This MetaKeyedDecodingContainer's meta.
     */
    open let meta: KeyedContainerMeta
    
    /**
     The decoder that created this container.
     
     Decoding, creating new containers and creating super decoders is delegated to it.
     */
    open let decoder: MetaDecoder
    
    open let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(for meta: KeyedContainerMeta, at codingPath: [CodingKey], decoder: MetaDecoder) {
        
        self.meta = meta
        self.codingPath = codingPath
        self.decoder = decoder
        
    }
    
    // MARK: - container methods
    
    public var allKeys: [Key] {
        
        return meta.allKeys() as [Key]
        
    }
    
    public func contains(_ key: Key) -> Bool {
        
        return meta.contains(key: key)
        
    }
    
    // MARK: - decoding
    
    public func decodeNil(forKey key: Key) throws -> Bool {
        
        return try accessMeta(at: key) is NilMetaProtocol
        
    }
    
    public func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        
        let subMeta = try accessMeta(at: key)
        return try decoder.unwrap(subMeta, toType: type, for: key)
        
    }
    
    // MARK: - nested containers
    
    open func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        let subMeta = try accessMeta(at: key)
        return try decoder.container(keyedBy: keyType, for: subMeta, at: codingPath + [key])
        
    }
    
    open func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        
        let subMeta = try accessMeta(at: key)
        return try decoder.unkeyedContainer(for: subMeta, at: codingPath + [key])
        
    }
    
    // MARK: - super decoder
    
    open func superDecoder() throws -> Decoder {
        return try self.superDecoderImpl(forKey: SpecialCodingKey.super.rawValue)
    }
    
    open func superDecoder(forKey key: K) throws -> Decoder {
        return try self.superDecoderImpl(forKey: key)
    }
    
    func superDecoderImpl(forKey key: CodingKey) throws -> Decoder {
        
        let subMeta = try accessMeta(at: key)
        return try decoder.decoder(for: subMeta, at: codingPath + [key])
        
    }
    
    // MARK: - utilities
    
    private func accessMeta(at key: CodingKey) throws -> Meta {
        
        guard let subMeta = meta[key] else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "No container for key \(key) found.")
            throw DecodingError.keyNotFound(key, context)
            
        }
        
        return subMeta
        
    }
    
}
