//
//  SimpleGenericMeta.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

open class SimpleGenericMeta<T>: GenericMeta {
    
    public typealias SwiftValueType = T
    
    open var value: T
    
    public init(value: T) {
        self.value = value
    }
    
}
