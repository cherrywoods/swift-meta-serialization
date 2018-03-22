//
//  Dictionary+KeyedContainerMeta.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See https://www.unlicense.org
// 

#if swift(>=4.1)

import Foundation

extension Dictionary: KeyedContainerMeta, Meta where Key == String, Value: Meta {
    
    /*
     I assume that all CodingKeys are fully identified by their string values,
     although I cloudn't find any documentation about this topic.
     
     However, JSONDecoder from swift standard library does the same.
     */
    
    public typealias SwiftValueType = Dictionary<String, Meta>
    
    public subscript(key: CodingKey) -> Meta? {
        
        get {
            return self[key.stringValue]
        }
        
        set {
            self[key.stringValue] = newValue as! Value?
        }
        
    }
    
    public func allKeys<Key: CodingKey>() -> [Key] {
        return keys.compactMap { Key(stringValue: $0) }
    }
    
    public func contains(key: CodingKey) -> Bool {
        return self[key.stringValue] != nil
    }
    
}

#endif
