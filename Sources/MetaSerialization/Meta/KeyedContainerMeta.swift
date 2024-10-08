//
//  KeyedContainerMeta.swift
//  MetaSerialization
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

public typealias KeyedContainerMeta = EncodingKeyedContainerMeta&DecodingKeyedContainerMeta

/**
 A Meta for a keyed collection of Metas during encoding.
 The key is always a MetaCodingKey. 
 How these keys are handled internal is left to the implementation.
 */
public protocol EncodingKeyedContainerMeta: Meta {
    
    /// Stores `value`` for the `key` (replaces the old value if there is already a value stored for `key`).
    mutating func put(_ value: Meta, for key: MetaCodingKey)
    
    /// Returns the value contained for `key`` in this container, or nil if no value is contained. If `contains` returned true, this method returns a non-nil value.
    func getValue(for key: MetaCodingKey) -> Meta?
    
}

/**
 A Meta for a keyed collection of Metas during decoding.
 The key is always a MetaCodingKey. How these keys are handled internal is left to the implementation.
 */
public protocol DecodingKeyedContainerMeta: Meta {
    
    /// Returns the value contained for `key` in this container, or nil if no value is contained. If `contains` returned true, this method returns a non-nil value.
    func getValue(for key: MetaCodingKey) -> Meta?
    
    /// Returns all keys in this container as `MetaCodingKeys`.
    var allKeys: [MetaCodingKey] { get }
    
    /// Returns whether key is contained in this container.
    func contains(key: MetaCodingKey) -> Bool
    
}

/// A wrapper struct around arbitrary coding keys.
public struct MetaCodingKey {
    
    /// The string value of a coding key
    public let stringValue: String
    /// The int value of a coding key
    public let intValue: Int?
    
    /// Initalizes `stringValue` and `intValue` with the string and int values of `codingKey`.
    public init(codingKey: CodingKey) {
        
        self.stringValue = codingKey.stringValue
        self.intValue = codingKey.intValue
        
    }
    
    /// Initalizes with the given string and int value. The `intValue` is nil by default.
    public init(stringValue: String, intValue: Int? = nil) {
        
        self.stringValue = stringValue
        self.intValue = intValue
        
    }
    
}
