//
//  Foundation Primitive Codables.swift
//  MetaSerialization
//
//  Copyright 2018 cherrywoods
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/*

 In this file String, Bool, Float, Double, Int, Int8, Int16, Int32, Int64, UInt, UInt8, UInt16, UInt32 and UInt64
 are extended to conform to DirectlyCodable.

 This is done to prevent endless callbacks if a format (expressed by a MetaSupplier or an Unwrapper) does not support one of these types.

 Because if wrappingMeta returns nil for e.g. a String value,
 wrap will then call encode(to:) on this string again,
 it will request a single value container and call encode on this container,
 this leads to another call of encode(to:) on the string, and so on, and so on.

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
