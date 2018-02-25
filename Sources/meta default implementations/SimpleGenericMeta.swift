//
//  SimpleGenericMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 25.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

open class SimpleGenericMeta<T>: GenericMeta {
    
    public typealias SwiftValueType = T
    
    open var value: T
    
    public init(value: T) {
        self.value = value
    }
    
}
