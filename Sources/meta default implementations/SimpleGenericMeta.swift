//
//  SimpleGenericMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 25.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

open class SimpleGenericMeta<T>: GenericMeta {
    
    public typealias SwiftValueType = T
    
    public var value: T?
    
    public init() {  }
    
    public convenience init(value: T) {
        self.init()
        self.value = value
    }
    
}
