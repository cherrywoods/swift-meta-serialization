//
//  DictionaryKeyedMeta.swift
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

// TODO: replace with array extension

/**
 A implementation of KeyedContainerMeta, that uses a Dictionary of Strings and Metas to store key value mappings.
 
 This implementation uses the stringValue of each CodingKey as key. The intValues are ignored.
 */
open class DictionaryKeyedContainerMeta: KeyedContainerMeta, GenericMeta {
    
    /*
     I assume, that all CodingKeys are fully identified by theire stringValues,
     although I cloudn't find any documentation about this topic.
     
     However, JSONDecoder from swift standard library does the same.
     */
    
    public typealias SwiftValueType = Dictionary<String, Meta>
    
    public init() {
        // init with default value
    }
    
    /**
     The dictionary value of this container.
     */
    open var value: Dictionary<String, Meta> = [:]
    
    /**
     Set the value for a certain string key.
     */
    open subscript(stringKey: String) -> Meta? {
        
        get {
            return value[stringKey]
        }
        
        set {
            self.value[stringKey] = newValue
        }
        
    }
    
    // MARK: KeyedContainerMeta implementation
    
    open subscript(key: CodingKey) -> Meta? {
        
        get {
            return value[key.stringValue]
        }
        
        set {
            self.value[key.stringValue] = newValue
        }
        
    }
    
    open func allKeys<Key: CodingKey>() -> [Key] {
        return value.keys.flatMap { Key(stringValue: $0) }
    }
    
    open func contains(key: CodingKey) -> Bool {
        return value.contains(where: { (stringValue, _) in return key.stringValue == stringValue })
    }
    
}
