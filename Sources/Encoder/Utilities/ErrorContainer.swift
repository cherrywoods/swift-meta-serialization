//
//  ErrorContainer.swift
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

// the idea for this kind of container came up for me first in https://forums.swift.org/t/nestedcontainer-in-keyedencodingcontainer-and-unkeyedencodingcontainer-should-be-throwing/11566

import Foundation

/// An Encoder that returns an `ErrorContainer` in all methods.
public typealias ErrorEncoder = ErrorContainer

/// A keyed, unkeyed, single value container and encoder that will throw an error in all methods it can throw and return another `KeyedErrorContainer` in all other methods.
public typealias ErrorContainer = KeyedErrorContainer<StandardCodingKey>

/// A keyed, unkeyed, single value container and encoder that will throw an error in all methods it can throw and return another `KeyedErrorContainer` in all other methods.
public struct KeyedErrorContainer<K: CodingKey>: Encoder, KeyedEncodingContainerProtocol, UnkeyedEncodingContainer, SingleValueEncodingContainer {
    
    public let codingPath: [CodingKey]
    public let userInfo: [CodingUserInfoKey : Any]
    
    /// The error this container throws
    public let error: Error
    
    /// Initalize a new `KeyedErrorContainer` with the given error, coding path and user info dictionary.
    public init(error: Error, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.error = error
    }
    
    // MARK: creating new error containers
    
    static func newContainer<AnotherKey>(keyedBy keyType: AnotherKey.Type, with error: Error, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any] = [:]) -> KeyedEncodingContainer<AnotherKey> {
        return KeyedEncodingContainer(KeyedErrorContainer<AnotherKey>(error: error, codingPath: codingPath, userInfo: userInfo))
    }
    
    // MARK: encode
    
    public mutating func encodeNil() throws {
        throw error
    }
    
    public mutating func encode<T>(_ value: T) throws where T : Encodable {
        try encodeNil()
    }
    
    // MARK: encoder
    
    public func container<AnotherKey>(keyedBy type: AnotherKey.Type) -> KeyedEncodingContainer<AnotherKey> where AnotherKey : CodingKey {
        return KeyedErrorContainer.newContainer(keyedBy: type, with: error, codingPath: codingPath, userInfo: userInfo)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return self
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
    
    // MARK: superEncoder
    
    public mutating func superEncoder() -> Encoder {
        return self
    }
    
    // MARK: keyed container
    
    public typealias Key = K
    
    public mutating func encodeNil(forKey key: K) throws {
        try encodeNil()
    }
    
    public mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        try encodeNil()
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return container(keyedBy: keyType)
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return unkeyedContainer()
    }
    
    public mutating func superEncoder(forKey key: K) -> Encoder {
        return superEncoder()
    }
    
    // MARK: unkeyed contaienr
    
    public let count: Int = 0
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return container(keyedBy: keyType)
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return unkeyedContainer()
    }
    
}
