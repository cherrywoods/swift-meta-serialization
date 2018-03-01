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
        
        let path = self.codingPath
        
        // there needs to be a placeholder or a real meta stored at the path
        
        // if there is a meta stored at path and it isn't a KeyedContainerMeta, crash
        
        if storage.storesMeta(at: path) {
            
            guard storage[codingPath] is KeyedContainerMeta else {
                
                preconditionFailure("Requested a diffrent container type at a previously used coding path.")
                
            }
            
        }
        
        let reference = Reference.direct(storage.storage, path)
        return self.container(keyedBy: keyType, referencing: reference, at: path)
        
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        
        let path = self.codingPath
        
        if storage.storesMeta(at: codingPath) {
            
            guard storage[codingPath] is UnkeyedContainerMeta else {
                preconditionFailure("Requested a second container at a previously used coding path.")
            }
            
        }
        
        let reference = Reference.direct(storage.storage, path)
        return self.unkeyedContainer(referencing: reference, at: path)
        
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        
        // A little bit strangely but not easily preventable,
        // a entity can request a keyed or unkeyed container
        // and then request a SingleValueContainer reffering to the meta of the keyed or unkeyed container.
        
        // if an entity tries to encode twice at the same path, the single value container will fail, but this function will succeed
        
        let path = self.codingPath
        
        let reference = Reference.direct(storage.storage, path)
        return self.singleValueContainer(referencing: reference, at: path)
        
    }
    
}
