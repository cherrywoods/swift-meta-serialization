//
//  WrappingMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 26.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

/**
 A Meta for wrapping arbitrary values in strings
 
 For wrapping into a String, extensions and existing meta implementations in this framwork exist, if the type you'd like to wrap conforms to LosslessStringConvertible (implementations only for the most types).
 */
public protocol WrappingMeta: Meta {
    
    /// the swift type, that shawl be wrapped into WrappingType
    associatedtype WrappedType
    /// the type that is used in raw representations
    associatedtype WrapperType
    
    var wrappedValue: WrappedType! { get set }
    
    /**
     Convert the wrapped type into a WrapperType representation, that will convert back to the same wrapped value, if it is passed to convert(wrapper:).
     Therefor return a representation, that identifies the wrapped value.
     */
    func convert(wrapped: WrappedType) -> WrapperType
    
    /**
     Convert a wrapper type representation into the corresponding wrapped type.
     You may assume, that wrapper is a valid representation you yourself created.
     */
    func convert(wrapper: WrapperType) -> WrappedType?
    
}

public extension WrappingMeta {
    
    public func get() -> Any? {
        
        return wrappedValue == nil ? nil : convert(wrapped: wrappedValue!)
        
    }
    
    public mutating func set(value: Any) {
        
        precondition(value is WrapperType, "Incorrect usage of WrappingMeta. set(value:) was called with unexpected type. (expected type: \(WrapperType.self)")
        self.wrappedValue = convert(wrapper: value as! WrapperType)
        
    }
    
}
