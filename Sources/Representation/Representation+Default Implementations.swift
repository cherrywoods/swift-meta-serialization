//
//  Representation+Default Implementations.swift
//  meta-serialization
//
//  Created by cherrywoods on 23.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

public extension Representation {
    
    public var encoder: MetaEncoder {
        return self.coder.encoder
    }
    
    public var decoder: MetaDecoder {
        return self.coder.decoder
    }
    
}

public extension EncodingRepresentation {
    
    public var codingPath: [CodingKey] {
        return self.encoder.codingPath
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.encoder.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return self.encoder.container(keyedBy: type)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return self.encoder.unkeyedContainer()
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self.encoder.singleValueContainer()
    }
    
}

public extension DecodingRepresentation {
    
    public var codingPath: [CodingKey] {
        return self.decoder.codingPath
    }
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.decoder.userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return try self.decoder.container(keyedBy: type)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try self.decoder.unkeyedContainer()
    }
    
    public func singleValueContainer() -> SingleValueDecodingContainer {
        return self.decoder.singleValueContainer()
    }
    
}
