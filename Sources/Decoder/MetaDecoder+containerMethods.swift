//
//  MetaDecoder+containerMethods.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation

public extension MetaDecoder {
    
    public func container<Key: CodingKey>(keyedBy keyType: Key.Type) throws -> KeyedDecodingContainer<Key> {
        
        let path = codingPath
        return try container(keyedBy: keyType, for: storage[path], at: path)
        
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        let path = codingPath
        return try unkeyedContainer(for: storage[path], at: path)
        
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        
        let path = codingPath
        return try singleValueContainer(for: storage[path], at: path)
        
    }
    
}
