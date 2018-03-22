//
//  SimpleGenericMeta.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

/**
 A simple default implementation for metas that do only wrap another value.
 */
public struct SimpleGenericMeta<T>: GenericMeta {
    
    public typealias SwiftValueType = T
    
    /**
     The value this meta is wrapping.
     */
    public let value: T
    
    /**
     Init a new SimpleGenericMeta with the given value
     */
    public init(value: T) {
        self.value = value
    }
    
}
