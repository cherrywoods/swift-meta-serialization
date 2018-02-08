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
    
    public var value: T!
    
    public init() {  }
    
    public convenience init(value: T) {
        self.init()
        self.value = value
    }
    
}
