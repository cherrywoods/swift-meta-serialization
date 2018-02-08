//
//  WrapInStringMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 26.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

public extension WrappingMeta where WrappingType == String, WrappedType: LosslessStringConvertible {
    
    public func convert(wrapped: WrappedType) -> WrappingType {
        return wrapped.description
    }
    
    public func convert(wrapping string: WrappingType) -> WrappedType? {
        return WrappedType.init(string)!
    }
    
}
