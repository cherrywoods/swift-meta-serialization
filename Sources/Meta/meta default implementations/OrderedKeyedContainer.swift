//
//  OrderedDictionaryMeta.swift
//  MetaSerialization
//
//  Copyright 2024 cherrywoods
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

public struct OrderedKeyedContainer: KeyedContainerMeta, Meta {

    private var elements = [(key: String, value: Meta)]()
    private var keyLookup =  [String: Int]()

    public init() {}

    public var ordered: [(key: String, value: Meta)] {
        return self.elements
    }

    public var dictionary: [String: Meta] {
        return Dictionary(uniqueKeysWithValues: self.elements)
    }
    
    public var allKeys: [MetaCodingKey] {
        
        return elements.map { MetaCodingKey(stringValue: $0.key) }
        
    }
    
    public func contains(key: MetaCodingKey) -> Bool {
        
        // if subscript returns nil, there is no value contained
        return self.keyLookup[key.stringValue] != nil
        
    }
    
    public mutating func put(_ value: Meta, for key: MetaCodingKey) {
        
        let key = key.stringValue

        if let index = self.keyLookup[key] {
            self.elements[index] = (key: key, value: value)
        } else {
            self.elements.append((key: key, value: value))
            self.keyLookup[key] = self.elements.count - 1
        }
        
    }
    
    public func getValue(for key: MetaCodingKey) -> Meta? {
        
        if let index = self.keyLookup[key.stringValue] {
            return self.elements[index].value
        } else {
            return nil
        }
        
    }
    
}
