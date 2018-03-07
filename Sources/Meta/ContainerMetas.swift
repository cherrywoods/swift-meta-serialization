//
//  ContainerMetas.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 A meta for a keyed collection of metas.
 
 The key is always a CodingKey. How these keys are handled internal is left to the implementor.
 */
public protocol KeyedContainerMeta: Meta {
    
    /**
     Access the value inside this container for key.
     
     Return nil, if there's no value contained for this key.
     
     You may not return nil, if contains returned true for the key.
     */
    subscript(key: CodingKey) -> Meta? { get set }
    
    /**
     Returns all keys in this container as a certain CodingKey implementation.
     
     Internal key representations, that could not be converted to the given kind of CodingKey may be ommited from the returned collection, if you can safely assume, that your representation fully identifies a CodingKey.
     */
    func allKeys<Key>() -> [Key] where Key: CodingKey
    /// returns whether key is contained in this container
    func contains(key: CodingKey) -> Bool
    
}

/**
 A meta for a unkeyed collection of metas.
 
 The indexiation starts at 0 and ends at count-1, with steps of size 1 (if you have 4 elements, they have to be indexed 0,1,2,3).
 
 You may not use custom indexes, if you liked meta-serialization to work properly.
 */
public protocol UnkeyedContainerMeta: Meta {
    
    /**
     The number of elements in the container, return 0, if no element is contained.
     
     Return nil, if the number is unknown.
     You may not return nil during encoding.
    */
    var count: Int? { get }
    
    /**
     Returns the element at the given index
     or nil, if the index is smaller than 0 or bigger or equal than count.
     */
    func get(at index: Int) -> Meta?
    
    /**
     Inserts or appends the given meta at index.
     Index may be equals count (in this case you should append), but not larger.
     */
    func insert(element: Meta, at: Int)
    
    
}