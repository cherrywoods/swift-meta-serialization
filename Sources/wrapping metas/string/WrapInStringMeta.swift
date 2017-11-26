//
//  WrapInStringMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 26.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
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
