//
//  MetaEncoder+containerMethods.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation

public extension MetaEncoder {
    
    public func container<Key>(keyedBy keyType: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        
        let path = codingPath
        
        // there needs to be a placeholder or a real meta stored at the path
        // if there is a meta stored at path and it isn't a KeyedContainerMeta, crash
        
        let alreadyStoringContainer = storage.storesMeta(at: path)
        if alreadyStoringContainer {
            
            guard storage[codingPath] is KeyedContainerMeta else {
                preconditionFailure("Requested a diffrent container type at a previously used coding path.")
            }
            
        }
        
        let reference = Reference.direct(storage.storage, path)
        // only create a new container, if there isn't already one
        return container(keyedBy: keyType, referencing: reference, at: path, createNewContainer: !alreadyStoringContainer)
        
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        
        let path = codingPath
        
        let alreadyStoringContainer = storage.storesMeta(at: path)
        if alreadyStoringContainer {
            
            guard storage[codingPath] is UnkeyedContainerMeta else {
                preconditionFailure("Requested a second container at a previously used coding path.")
            }
            
        }
        
        let reference = Reference.direct(storage.storage, path)
        return unkeyedContainer(referencing: reference, at: path, createNewContainer: !alreadyStoringContainer)
        
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        
        // A little bit strangely but not easily preventable,
        // a entity can request a keyed or unkeyed container
        // and then request a SingleValueContainer reffering to the meta of the keyed or unkeyed container.
        
        let path = codingPath
        let reference = Reference.direct(storage.storage, path)
        
        return singleValueContainer(referencing: reference, at: path)
        
    }
    
}
