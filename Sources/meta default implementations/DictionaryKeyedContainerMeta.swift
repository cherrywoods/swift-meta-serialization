//
//  DictionaryKeyedMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 24.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

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
     The arry value of this container.
     
     Note that you may never set it to nil and that it never will be nil.
     */
    open var value: Dictionary<String, Meta>? = [:] {
        willSet {
            // this precondition enables the save use of ! in the implementations below
            precondition(newValue != nil,
                         "The value property of an DictionaryKeyedContainerMeta may never be nil. Do not set it to nil. If you wan't to delete all key-value-pairs, set it to [:].")
        }
    }
    
    /**
     Set the value for a certain string key.
     */
    open subscript(stringKey: String) -> Meta? {
        
        get {
            return value![stringKey]
        }
        
        set {
            self.value![stringKey] = newValue
        }
        
    }
    
    open subscript(key: CodingKey) -> Meta? {
        
        get {
            return value![key.stringValue]
        }
        
        set {
            self.value![key.stringValue] = newValue
        }
        
    }
    
    open func allKeys<Key: CodingKey>() -> [Key] {
        return value!.keys.flatMap { Key(stringValue: $0) }
    }
    
    open func contains(key: CodingKey) -> Bool {
        return value!.contains(where: { (stringValue, _) in return key.stringValue == stringValue })
    }
    
}
