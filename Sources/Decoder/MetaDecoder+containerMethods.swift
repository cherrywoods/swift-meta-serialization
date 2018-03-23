//
//  MetaDecoder+containerMethods.swift
//  MetaSerialization
//
//  Copyright 2018 cherrywoods
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
