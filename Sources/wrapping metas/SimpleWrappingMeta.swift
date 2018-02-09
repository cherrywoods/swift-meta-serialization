//
//  SimpleWrappingMeta.swift
//  MetaSerialization
//
//  Created by cherrywoods on 09.02.18.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

public struct SimpleWrappingMeta<Wrapper, Wrapped>: WrappingMeta {
    
    public typealias WrappedType = Wrapped
    public typealias WrapperType = Wrapper
    
    private let convertWrapped: (Wrapped) -> Wrapper
    private let convertWrapper: (Wrapper) -> Wrapped
    
    public init(convertToWrapperType: @escaping (Wrapped) -> Wrapper,
                convertFromWrapperType: @escaping (Wrapper) -> Wrapped) {
        
        self.convertWrapped = convertToWrapperType
        self.convertWrapper = convertFromWrapperType
        
    }
    
    public var wrappedValue: Wrapped!
    
    public func convert(wrapped: Wrapped) -> Wrapper {
        return convertWrapped(wrapped)
    }
    
    public func convert(wrapper: Wrapper) -> Wrapped? {
        return convertWrapper(wrapper)
    }
    
}
