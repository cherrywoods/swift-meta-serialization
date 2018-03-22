//
//  MetaSupplier+Defaults.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See https://www.unlicense.org
// 

import Foundation

public extension MetaSupplier {
    
    // TODO: update when these containers are rewritten. Also update documenation.
    
    public func keyedContainerMeta() -> KeyedContainerMeta {
        return DictionaryKeyedContainerMeta()
    }
    
    public func unkeyedContainerMeta() -> UnkeyedContainerMeta {
        return ArrayUnkeyedContainerMeta()
    }
    
}
