//
//  Foundation Primitive Codables.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/*

 In this file,
 String, Bool, Float, Double,
 Int, Int8, Int16, Int32, Int64,
 UInt, UInt8, UInt16, UInt32, UInt64
 are extended to conform to DirectlyCodable.

 This is done to prevent endless callbacks
 if a translator does not support one of these types.

 Because if wrappingMeta returns nil
 for e.g. a String value,
 wrap will then call encode(to:)
 on this string again,
 it will request a single value container
 and call encode on this container,
 this leads to another call of encode(to:)
 on the string, and so on, and so on.

 */

// TODO: does it make sence to make these extension public?

public extension String: DirectlyCodable {}

public extension Bool: DirectlyCodable {}

public extension Float: DirectlyCodable {}
public extension Double: DirectlyCodable {}

public extension Int: DirectlyCodable {}
public extension Int8: DirectlyCodable {}
public extension Int16: DirectlyCodable {}
public extension Int32: DirectlyCodable {}
public extension Int64: DirectlyCodable {}

public extension UInt: DirectlyCodable {}
public extension UInt8: DirectlyCodable {}
public extension UInt16: DirectlyCodable {}
public extension UInt32: DirectlyCodable {}
public extension UInt64: DirectlyCodable {}
