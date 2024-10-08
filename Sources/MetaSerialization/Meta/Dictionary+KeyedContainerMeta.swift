//
//  Dictionary+KeyedContainerMeta.swift
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

extension Dictionary: KeyedContainerMeta, Meta where Key == String, Value == Meta {
    
    // I assume that all CodingKeys are fully identified by their string values,
    // although I cloudn't find any documentation about this topic.
    // However, JSONDecoder from swift standard library does the same.
    
    public var allKeys: [MetaCodingKey] {
        
        return keys.map { MetaCodingKey(stringValue: $0) }
        
    }
    
    public func contains(key: MetaCodingKey) -> Bool {
        
        // if subscript returns nil, there is no value contained
        return self[key.stringValue] != nil
        
    }
    
    public mutating func put(_ value: Meta, for key: MetaCodingKey) {
        
        self[key.stringValue] = value
        
    }
    
    public func getValue(for key: MetaCodingKey) -> Meta? {
        
        return self[key.stringValue]
        
    }
    
}
