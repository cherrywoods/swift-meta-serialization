//
//  EmptyOnlyKeyedContainerMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 18.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

/**
 A special keyed container meta, that just indicates total emptyness.
 */
public struct EmptyOnlyKeyedContainerMeta: KeyedContainerMeta {
    
    /// will return an empty array
    public func allKeys<Key>() -> [Key] where Key : CodingKey {
        return []
    }
    
    /// will return false
    public func contains(key: CodingKey) -> Bool {
        return false
    }
    
    /// will return a NilMeta on get and do nothing on set.
    public subscript(key: CodingKey) -> Meta? {
        get {
            return NilMeta.nil
        }
        set {
            // Just do nothing
        }
    }
    
    /// will do nothing
    public func set(value: Any) {
        // nada
    }
    
    /// will return a NilMeta
    public func get() -> Any? {
        return NilMeta.nil
    }
    
}
