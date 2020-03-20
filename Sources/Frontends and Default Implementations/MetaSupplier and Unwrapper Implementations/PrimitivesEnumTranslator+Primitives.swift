//
//  PrimitivesEnumTranslator+primitives.swift
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

public extension PrimitivesEnumTranslator {
    
    /**
     This enum contains cases for all primitive types PrimitivesEnumTranslator can handle.
     The provided cases correspond to the types from the standard library, that have no mode of serializing themselves to another type (rely on a SingleValue(Encoding/Decoding)Container).
     */
    enum Primitive: Hashable {
        
        /// stands for swifts String type
        case string
        /// stands for swifts Bool type
        case bool
        /// stands for swifts Float type
        case float
        /// stands for swifts Double type
        case double
        /// stands for swifts Int type
        case int
        /// stands for swifts UInt type
        case uInt
        /// stands for swifts Int8 type
        case int8
        /// stands for swifts UInt8 type
        case uInt8
        /// stands for swifts Int16 type
        case int16
        /// stands for swifts UInt16 type
        case uInt16
        /// stands for swifts Int32 type
        case int32
        /// stands for swifts UInt32 type
        case uInt32
        /// stands for swifts Int64 type
        case int64
        /// stands for swifts UInt64 type
        case uInt64
        /// stands for any nil value
        case `nil`
        
        /// lists all Primitive cases
        public static var all: Set<Primitive> {
            return Set<Primitive>(arrayLiteral: .string, .bool, .float, .double, .int, .uInt, .int8, .uInt8, .int16, .uInt16, .int32, .uInt32, .int64, .uInt64, .nil )
        }
        
        /// Creates a new Primitive for the given type if it matches one of this enums cases.
        public init?<T>(from type: T.Type) {
            
            if        type.self is String.Type {
                self = .string
            } else if type.self is Bool.Type {
                self = .bool
            } else if type.self is Float.Type {
                self = .float
            } else if type.self is Double.Type {
                self = .double
            } else if type.self is Int.Type {
                self = .int
            } else if type.self is UInt.Type {
                self = .uInt
            } else if type.self is Int8.Type {
                self = .int8
            } else if type.self is UInt8.Type {
                self = .uInt8
            } else if type.self is Int16.Type {
                self = .int16
            } else if type.self is UInt16.Type {
                self = .uInt16
            } else if type.self is Int32.Type {
                self = .int32
            } else if type.self is UInt32.Type {
                self = .uInt32
            } else if type.self is Int64.Type {
                self = .int64
            } else if type.self is UInt64.Type {
                self = .uInt64
            } else if type.self is NilMarker.Type {
                self = .nil
            } else {
                return nil
            }
            
        }
        
    }
    
}

internal protocol PrimitivesEnumTranslatorPrimitives: Meta {}

extension String: PrimitivesEnumTranslatorPrimitives {}
extension Bool: PrimitivesEnumTranslatorPrimitives {}
extension Float: PrimitivesEnumTranslatorPrimitives {}
extension Double: PrimitivesEnumTranslatorPrimitives {}
extension Int: PrimitivesEnumTranslatorPrimitives {}
extension UInt: PrimitivesEnumTranslatorPrimitives {}
extension Int8: PrimitivesEnumTranslatorPrimitives {}
extension UInt8: PrimitivesEnumTranslatorPrimitives {}
extension Int16: PrimitivesEnumTranslatorPrimitives {}
extension UInt16: PrimitivesEnumTranslatorPrimitives {}
extension Int32: PrimitivesEnumTranslatorPrimitives {}
extension UInt32: PrimitivesEnumTranslatorPrimitives {}
extension Int64: PrimitivesEnumTranslatorPrimitives {}
extension UInt64: PrimitivesEnumTranslatorPrimitives {}
extension NilMarker: PrimitivesEnumTranslatorPrimitives {}
