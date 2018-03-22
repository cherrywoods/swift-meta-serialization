//
//  DictionaryKeyedMeta.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
