//
//  StringWrapperStandardTypes.swift
//  meta-serialization
//
//  Created by cherrywoods on 26.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

// MARK: Bool

public struct BoolWrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Bool
    public typealias WrapperType = String
    public var wrappedValue: Bool!
}

// MARK: Int

public struct IntWrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Int
    public typealias WrapperType = String
    public var wrappedValue: Int!
}

public struct Int8WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Int8
    public typealias WrapperType = String
    public var wrappedValue: Int8!
}

public struct Int16WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Int16
    public typealias WrapperType = String
    public var wrappedValue: Int16!
}

public struct Int32WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Int32
    public typealias WrapperType = String
    public var wrappedValue: Int32!
}

public struct Int64WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Int64
    public typealias WrapperType = String
    public var wrappedValue: Int64!
}

// MARK: UInt

public struct UIntWrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = UInt
    public typealias WrapperType = String
    public var wrappedValue: UInt!
}

public struct UInt8WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = UInt8
    public typealias WrapperType = String
    public var wrappedValue: UInt8!
}

public struct UInt16WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = UInt16
    public typealias WrapperType = String
    public var wrappedValue: UInt16!
}

public struct UInt32WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = UInt32
    public typealias WrapperType = String
    public var wrappedValue: UInt32!
}

public struct UInt64WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = UInt64
    public typealias WrapperType = String
    public var wrappedValue: UInt64!
}

// MARK: floating point values

public struct FloatWrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Float
    public typealias WrapperType = String
    public var wrappedValue: Float!
}

public struct DoubleWrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Double
    public typealias WrapperType = String
    public var wrappedValue: Double!
}

// MARK: Base 64 Data wrapper

/// Wrapps data values to base64 strings, using the default Base64EncodingOptions and Base64DecodingOptions.
public struct DataWrappedToStringUsingBase64Meta: WrappingMeta {
    
    public typealias WrappedType = Data
    public typealias WrapperType = String
    
    public var wrappedValue: Data!
    
    public func convert(wrapped: Data) -> String {
        return wrapped.base64EncodedString()
    }
    
    public func convert(wrapper: String) -> Data? {
        return Data(base64Encoded: wrapper)
    }
    
}
