//
//  EncodingContainerMeta.swift
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
@testable import MetaSerialization

protocol Example2EncodingContainerMeta {
    
    var array: [Meta] { get }
    
}

struct Example2EncodingKeyedContainerMeta: Example2EncodingContainerMeta, EncodingKeyedContainerMeta {
    
    var dictionary: [String : Meta] = [:]
    
    mutating func put(_ value: Meta, for key: MetaCodingKey) {
        
        dictionary[key.stringValue] = value
        
    }
    
    func getValue(for key: MetaCodingKey) -> Meta? {
        
        return dictionary[key.stringValue]
        
    }
    
    var array: [Meta] {
        
        // return alternating sequence of keys and values
        return dictionary.reduce([]) { var array = $0; array.append(Example2Meta.string($1.key)); array.append($1.value); return array }
        
    }
    
}

struct Example2EncodingUnkeyedContainerMeta: Example2EncodingContainerMeta, EncodingUnkeyedContainerMeta {
    
    var array: [Meta] = []
    
    var numberOfMetas: Int {
        return array.count
    }
    
    func get(at index: Int) -> Meta? {
        guard (0..<array.count).contains(index) else {
            return nil
        }
        return array[index]
    }
    
    mutating func insert(_ meta: Meta, at index: Int) {
        
        if index == array.count {
            // append in that case
            array.append(meta)
        } else {
            array[index] = meta
        }
        
    }
    
}
