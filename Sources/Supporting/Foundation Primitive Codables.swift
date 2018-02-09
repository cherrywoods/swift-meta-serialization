//
//  Foundation Primitive Codables.swift
//  MetaSerialization
//
//  Created by cherrywoods on 08.02.18.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
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

extension String: DirectlyCodable {}

extension Bool: DirectlyCodable {}

extension Float: DirectlyCodable {}
extension Double: DirectlyCodable {}

extension Int: DirectlyCodable {}
extension Int8: DirectlyCodable {}
extension Int16: DirectlyCodable {}
extension Int32: DirectlyCodable {}
extension Int64: DirectlyCodable {}

extension UInt: DirectlyCodable {}
extension UInt8: DirectlyCodable {}
extension UInt16: DirectlyCodable {}
extension UInt32: DirectlyCodable {}
extension UInt64: DirectlyCodable {}
