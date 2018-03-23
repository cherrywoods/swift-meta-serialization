//
//  PrimitivesEnumTranslator.swift
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

// TODO: change encode and decode
// TODO: in swift 5, after PrimitivesProtocolTranslator has been implemented, use that one with custom protocol Primitives: Meta and filter in wrap and unwrap as done right now.

/**
 A implementation of `MetaSupplier` and `Unwrapper`, that gets Metas out of your way, so you will only have to work with Arrays, Dictionarys and the Primitive types you pass to it. Call encode and decode to transfer from the meta tree MetaEncoder creates and MetaDecoder needs to your format.
 */
open class PrimitivesEnumTranslator: MetaSupplier, Unwrapper {
    
    /**
     This enum contains cases for all primitive types this Translator can handle.
     The provided cases correspond to the types from the standard library, that have no mode of serializing themselves to another type (rely on a SingleValue(Encoding/Decoding)Container).
     */
    public enum Primitive: Hashable {
        
        /// stands for the swift String type
        case string
        /// stands for the swift Bool type
        case bool
        /// stands for the swift Float type
        case float
        /// stands for the swift Double type
        case double
        /// stands for the swift Int type
        case int
        /// stands for the swift UInt type
        case uInt
        /// stands for the swift Int8 type
        case int8
        /// stands for the swift UInt8 type
        case uInt8
        /// stands for the swift Int16 type
        case int16
        /// stands for the swift UInt16 type
        case uInt16
        /// stands for the swift Int32 type
        case int32
        /// stands for the swift UInt32 type
        case uInt32
        /// stands for the swift Int64 type
        case int64
        /// stands for the swift UInt64 type
        case uInt64
        /// stands for a nil value
        case `nil`
        
        /// lists all Primitive cases
        public static var all: Set<Primitive> {
            return Set<Primitive>(arrayLiteral: .string, .bool, .float, .double, .int, .uInt, .int8, .uInt8, .int16, .uInt16, .int32, .uInt32, .int64, .uInt64, .nil )
        }
        
        /**
         Creates a new Primitive for the given swift type, if it is supported.
         */
        public init?<T>(fromSwiftType type: T.Type) {
            
            if          type.self is String.Type {
                self = .string
            } else if   type.self is Bool.Type {
                self = .bool
            } else if   type.self is Float.Type {
                self = .float
            } else if   type.self is Double.Type {
                self = .double
            } else if   type.self is Int.Type {
                self = .int
            } else if   type.self is UInt.Type {
                self = .uInt
            } else if   type.self is Int8.Type {
                self = .int8
            } else if   type.self is UInt8.Type {
                self = .uInt8
            } else if   type.self is Int16.Type {
                self = .int16
            } else if   type.self is UInt16.Type {
                self = .uInt16
            } else if   type.self is Int32.Type {
                self = .int32
            } else if   type.self is UInt32.Type {
                self = .uInt32
            } else if   type.self is Int64.Type {
                self = .int64
            } else if   type.self is UInt64.Type {
                self = .uInt64
            } else {
                return nil
            }
            
        }
        
    }
    
    /**
     Create a new PrimitivesEnumTranslator.
     If these conditions are violated, this initalizer will not return (crash).
     - Parameter primitives: A set of primitives types you can handle directly
     - Parameter encode: Your encoding closure. You may expect the Any? parameter to be one of your primitive types (and non-nil, if you did not added .nil to the primitives you passed), an array of already encoded values or a dictionary of Strings and already encoded values (it isn't possible to avoid these strings per se). The arrays and dictionarys might indeed contain nested arrays and dictionarys.
     - Parameter decode: Your decoding closure. You need to return one of your primitive types, an array of your primitive types, or a dictionary of Strings and your primitive types (or with nested arrays and dictionarys).
     */
    public init( primitives: Set<Primitive>,
                 encode: @escaping (Any?) throws -> Any?,
                 decode: @escaping (Any?) throws -> Any? ) {
        
        self.primitives = primitives
        
        self.encodingClosure = encode
        self.decodingClosure = decode
        
    }
    
    // MARK: properties
    
    private let primitives: Set<Primitive>
    
    private let encodingClosure: (Any?) throws -> Any?
    private let decodingClosure: (Any?) throws -> Any?
    
    // MARK: Translator implementation
    
    open func wrap<T>(for value: T, at codingPath: [CodingKey]) -> Meta? {
        
        // handle nil values first
        if T.self == GenericNil.self && primitives.contains(.nil) {
            return NilMeta.nil
        }
        
        // obtain primitive type of T
        guard let primitive = Primitive(fromSwiftType: T.self) else {
            // not a primitive type
            return nil
        }
        
        // return a SimpleGenericMeta for the supported primitive types
        if primitives.contains(primitive) {
            
            return SimpleGenericMeta<T>(value: value)
            
        } else {
            // not a supported primitive type
            return nil
            
        }
        
    }
    
    // Use the default implementations of keyedContainerMeta and unkeyedContainerMeta
    
    open func unwrap<T>(meta: Meta, toType type: T.Type, at codingPath: [CodingKey]) throws -> T? {
        
        // NilMetas will not reach here
        
        if let primitive = Primitive(fromSwiftType: type) {
            
            // handle primitives
            if primitives.contains(primitive) {
                
                // now meta needs to be a SimpleGenericMeta<T>
                // if it is not, throw an error.
                // It means that the requested type is wrong
                
                guard let value = (meta as? SimpleGenericMeta<T>)?.value else {
                    let context = DecodingError.Context(codingPath: codingPath,
                                                        debugDescription: "Decoded value did not match requested type")
                    throw DecodingError.typeMismatch(type, context)
                }
                
                return value
                
            } else {
                // not a supported primitive type
                return nil
            }
            
        } else {
            // not a primitive type
            return nil
        }
        
    }
    
    open func encode<R>(_ meta: Meta) throws -> R {
        
        // Meta is garanteed to be a SimpleGenericMeta of one of the Primitive types
        // or a NilMeta or a DictionaryKeyedContainerMeta or an ArrayUnkeyedContainerMeta
        // that are both GenericMetas
        
        let value: Any?
        if meta is NilMeta {
            
            value = nil
            
        } else if meta is DictionaryKeyedContainerMeta {
            
            let d = (meta as! DictionaryKeyedContainerMeta).value
            value = try d.mapValues { return try encode($0) as R }
            
        } else if meta is ArrayUnkeyedContainerMeta {
            
            let a = (meta as! ArrayUnkeyedContainerMeta).value
            value = try a.map { return try encode($0) as R }
            
        } else {
            
            if meta is SimpleGenericMeta<String> {
                value = (meta as! SimpleGenericMeta<String>).value
                
            } else if meta is SimpleGenericMeta<Bool> {
                value = (meta as! SimpleGenericMeta<Bool>).value
                
            } else if meta is SimpleGenericMeta<Float> {
                value = (meta as! SimpleGenericMeta<Float>).value
                
            } else if meta is SimpleGenericMeta<Double> {
                value = (meta as! SimpleGenericMeta<Double>).value
                
            } else if meta is SimpleGenericMeta<Int> {
                value = (meta as! SimpleGenericMeta<Int>).value
                
            } else if meta is SimpleGenericMeta<UInt> {
                value = (meta as! SimpleGenericMeta<UInt>).value
                
            } else if meta is SimpleGenericMeta<Int8> {
                value = (meta as! SimpleGenericMeta<Int8>).value
                
            } else if meta is SimpleGenericMeta<UInt8> {
                value = (meta as! SimpleGenericMeta<UInt8>).value
                
            } else if meta is SimpleGenericMeta<Int16> {
                value = (meta as! SimpleGenericMeta<Int16>).value
                
            } else if meta is SimpleGenericMeta<UInt16> {
                value = (meta as! SimpleGenericMeta<UInt16>).value
                
            } else if meta is SimpleGenericMeta<Int32> {
                value = (meta as! SimpleGenericMeta<Int32>).value
                
            } else if meta is SimpleGenericMeta<UInt32> {
                value = (meta as! SimpleGenericMeta<UInt32>).value
                
            } else if meta is SimpleGenericMeta<Int64> {
                value = (meta as! SimpleGenericMeta<Int64>).value
                
            } else if meta is SimpleGenericMeta<UInt64> {
               value = (meta as! SimpleGenericMeta<UInt64>).value
                
            } else {
                preconditionFailure("Unknown Meta")
            }
            
        }
        
        // value is eigther a primitive type
        // or Dictionary<String, primitive type>
        // or Array<primitive type>
        return try self.encodingClosure(value) as! R
        
    }
    
    open func decode<R>(_ raw: R) throws -> Meta {
        
        // decode and create Metas
        let value = try self.decodingClosure(raw)
        return createMeta(from: value)
        
    }
    
    private func createMeta(from value: Any?) -> Meta {
        
        // check nil in the first place
        if value == nil {
            
            if primitives.contains(.nil) {
                return NilMeta.nil
            } else {
                preconditionFailure("May not return nil in \(self.decodingClosure), if no support for nil as primitive type is given.")
            }
            
        }
        
        // check for keyed container
        if let dictionary = value! as? Dictionary<String, Any?> {
            
            // create metas for values first (recursively)
            var metaDict = Dictionary<String, Meta>(minimumCapacity: dictionary.capacity)
            for (key, value) in dictionary {
                metaDict[key] = createMeta(from: value)
            }
            
            let meta = DictionaryKeyedContainerMeta()
            meta.value = metaDict
            return meta
            
        }
        
        if let array = value! as? Array<Any?> {
            
            // create metas for values first (recursively)
            let metaArray = array.map { return createMeta(from: $0) }
            
            let meta = ArrayUnkeyedContainerMeta()
            meta.value = metaArray
            return meta
            
        }
        // return SimpleGenericMeta for the simple (and primitive) types
        // Wrappers will be applied in unwrap, when the final type is known
        if let string = value! as? String {
            return SimpleGenericMeta(value: string)
            
        } else if let boolean = value! as? Bool {
            return SimpleGenericMeta(value: boolean)
            
        } else if let float = value! as? Float {
            return SimpleGenericMeta(value: float)
            
        } else if let double = value! as? Double {
            return SimpleGenericMeta(value: double)
            
        } else if let int = value! as? Int {
            return SimpleGenericMeta(value: int)
            
        } else if let uint = value! as? UInt {
            return SimpleGenericMeta(value: uint)
            
        } else if let int8 = value! as? Int8 {
            return SimpleGenericMeta(value: int8)
            
        } else if let uint8 = value! as? UInt8 {
            return SimpleGenericMeta(value: uint8)
            
        } else if let int16 = value! as? Int16 {
            return SimpleGenericMeta(value: int16)
            
        } else if let uint16 = value! as? UInt16 {
            return SimpleGenericMeta(value: uint16)
            
        } else if let int32 = value! as? Int32 {
            return SimpleGenericMeta(value: int32)
            
        } else if let uint32 = value! as? UInt32 {
            return SimpleGenericMeta(value: uint32)
            
        } else if let int64 = value! as? Int64 {
            return SimpleGenericMeta(value: int64)
            
        } else if let uint64 = value! as? UInt64 {
            return SimpleGenericMeta(value: uint64)
            
        } else {
            
            preconditionFailure("\(self.decodingClosure) returned a non primitive, non dictionary, non array, non nil value: \(value!).") // nil check at the beginning of this func
            
        }
        
    }
    
}
