//
//  EmptyOnlyKeyedContainerMeta.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
            return nil
        }
        set {
            // Just do nothing
        }
    }
    
}
