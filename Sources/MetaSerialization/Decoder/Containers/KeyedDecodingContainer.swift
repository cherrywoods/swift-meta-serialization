//
//  KeyedDecodingContainer.swift
//  meta-serialization
//
//  Copyright 2018-2024 cherrywoods
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
 Manages a DecodingKeyedContainerMeta (for example, a Dictionary).
 */
open class MetaKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    
    public typealias Key = K
    
    /**
     This MetaKeyedDecodingContainer's Meta.
     */
    public let meta: DecodingKeyedContainerMeta
    
    /**
     The Decoder that created this container.
     
     Decoding, creating new containers, and creating super decoders is delegated to this Decoder.
     */
    public let decoder: MetaDecoder
    
    public let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(for meta: DecodingKeyedContainerMeta, at codingPath: [CodingKey], decoder: MetaDecoder) {
        
        self.meta = meta
        self.codingPath = codingPath
        self.decoder = decoder
        
    }
    
    // MARK: - container methods
    
    public var allKeys: [Key] {
        
        // filter all keys that are not convertible, as described in documentation
        return meta.allKeys.compactMap { metaKey in
            
            if let codingKey = Key(stringValue: metaKey.stringValue) {
                
                return codingKey
                
            }
            
            if let intValue = metaKey.intValue {
                
                return Key(intValue: intValue)
                
            }
                
            return nil
            
        }
        
    }
    
    public func contains(_ key: Key) -> Bool {
        
        return meta.contains(key: MetaCodingKey(codingKey: key))
        
    }
    
    // MARK: - decoding
    
    public func decodeNil(forKey key: Key) throws -> Bool {
        
        return try decoder.representsNil(meta: accessMeta(at: key))
        
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
    
    /// An utility method that acesses the meta stored at key and throws an error if the value isn't present.
    public func accessMeta(at key: CodingKey) throws -> Meta {
        
        guard let subMeta = meta.getValue(for: MetaCodingKey(codingKey: key)) else {
            
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "No container for key \(key) found.")
            throw DecodingError.keyNotFound(key, context)
            
        }
        
        return subMeta
        
    }
    
}
