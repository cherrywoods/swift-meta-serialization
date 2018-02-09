//
//  PrimitivesEnumTranslator.swift
//  MetaSerialization
//
//  Created by cherrywoods on 25.11.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 A implementation of Translator, that gets Metas out of your way, so you will only have to work with Arrays, Dictionarys and the Primitive types you pass to it.
 */
public class PrimitivesEnumTranslator: Translator {
    
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
     This enum contains cases for all swift types, to which PrimitivesEnumTranslator can wrapp other types.
     You may for example tell PrimitivesEnumTranslator on init, to wrap bool, int, uint8 and float to string.
     */
    public enum Wrapper {
        
        /// stands for the swift String type
        case string
        
        internal func primitiveType() -> PrimitivesEnumTranslator.Primitive {
            
            switch self {
            case .string:
                return .string
            }
            
        }
        
    }
    
    /**
     Create a new PrimitivesEnumTranslator
     
     primitives and wrappers.keys need to be disjoint (none of them may contain a element, the other also contains). Furthermore, wrappers.values needs to be fully contained in primitives.
     If these conditions are violated, this initalizer will not return (crash).
     - Parameter primitives: A set of primitives types you can handle directly
     - Parameter wrappers: A dictionary containing certain Primitive types and Wrapper types, to which the primitive types should be wrapped.
     - Parameter encode: Your encoding closure. You may expect the Any? parameter to be one of your primitive types (and non-nil, if you did not added .nil to the primitives you passed), an array of already encoded values or a dictionary of Strings and already encoded values (it isn't possible to avoid these strings per se). The arrays and dictionarys might indeed contain nested arrays and dictionarys.
     - Parameter decode: Your decoding closure. You need to return one of your primitive types, an array of your primitive types, or a dictionary of Strings and your primitive types (or with nested arrays and dictionarys).
     */
    public init( primitives: Set<Primitive>,
                 wrappers: [Primitive : Wrapper] = [:],
                 encode: @escaping (Any?) throws -> Any?,
                 decode: @escaping (Any?) throws -> Any? ) {
        
        // make sure wrappers.values is a subset of primitives
        // if the wrappers would not be primitives, we could not wrap to them
        precondition( primitives.isSuperset(of: wrappers.values.map() { $0.primitiveType() }),
                      "wrappers.values need to be subset of primitives" )
        
        // make sure wrappers.keys does not intersect with primitives
        // if a Primitive was contained in both, we had an ambiguity
        precondition( primitives.isDisjoint(with: wrappers.keys),
                      "wrappers.keys needs to be disjoint with primitives")
        
        self.primitives = primitives
        self.wrappers = wrappers
        
        self.encodingClosure = encode
        self.decodingClosure = decode
        
    }
    
    // MARK: properties
    
    private let primitives: Set<Primitive>
    private let wrappers: [Primitive : Wrapper]
    
    private let encodingClosure: (Any?) throws -> Any?
    private let decodingClosure: (Any?) throws -> Any?
    
    // MARK: Translator implementation
    
    public func wrappingMeta<T>(for value: T) -> Meta? {
        
        // handle nil values first
        if T.self == GenericNil.self && primitives.contains(.nil) {
            return NilMeta.nil
        }
        
        // obtain primitive type of T
        guard let primitive = Primitive(fromSwiftType: T.self) else {
            // not a primitive type
            return nil
        }
        
        // wrap wrappers
        if let wrapper = wrappers[primitive] {
            
            switch wrapper {
            case .string: // Use WrapInStringMeta
                switch primitive {
                case .bool:     return BoolWrappedToStringMeta()
                case .float:    return FloatWrappedToStringMeta()
                case .double:   return DoubleWrappedToStringMeta()
                case .int:      return IntWrappedToStringMeta()
                case .uInt:     return UIntWrappedToStringMeta()
                case .int8:     return Int8WrappedToStringMeta()
                case .uInt8:    return UInt8WrappedToStringMeta()
                case .int16:    return Int16WrappedToStringMeta()
                case .uInt16:   return UInt16WrappedToStringMeta()
                case .int32:    return Int32WrappedToStringMeta()
                case .uInt32:   return UInt32WrappedToStringMeta()
                case .int64:    return Int64WrappedToStringMeta()
                case .uInt64:   return UInt64WrappedToStringMeta()
                default: // this is .string and .nil (but nil is impossible), so just .string
                    // well this is nonesence
                    // but ok...
                    return SimpleGenericMeta<T>()
                }
            }
            
        }
        
        // return a SimpleGenericMeta for the supported primitive types
        if primitives.contains(primitive) {
            
            return SimpleGenericMeta<T>()
            
        } else {
            // not a supported primitive type
            return nil
            
        }
        
    }
    
    /*
     
     Use the default implementations of keyedContainerMeta and unkeyedContainerMeta
     
     */
    
    public func unwrap<T>(meta: Meta, toType type: T.Type) throws -> T? {
        
        // NilMetas will not reach here
        
        if let primitive = Primitive(fromSwiftType: type) {
            
            // now meta needs to be a SimpleGenericMeta<T>
            // if it is not, throw an error.
            // It means that the requested type is wrong
            
            guard let value = (meta as? SimpleGenericMeta<T>)?.value else {
                throw TranslatorError.typeMismatch
            }
            
            // handle wrapped values
            if let wrapper = wrappers[primitive] {
                switch wrapper {
                case .string:
                    let string = value as! String
                    switch primitive {
                    case .bool:     return Bool(string) as? T
                    case .float:    return Float(string) as? T
                    case .double:   return Double(string) as? T
                    case .int:      return Int(string) as? T
                    case .uInt:     return UInt(string) as? T
                    case .int8:     return Int8(string) as? T
                    case .uInt8:    return UInt8(string) as? T
                    case .int16:    return Int16(string) as? T
                    case .uInt16:   return UInt16(string) as? T
                    case .int32:    return Int32(string) as? T
                    case .uInt32:   return UInt32(string) as? T
                    case .int64:    return Int64(string) as? T
                    case .uInt64:   return UInt64(string) as? T
                    default: // this is .string and .nil (but nil is impossible), so just .string
                        // thats ofcourse nonsence, but I decided to tolerate it
                        return value
                    }
                }
            }
            
            // handle primitives
            if primitives.contains(primitive) {
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
    
    public func encode<R>(_ meta: Meta) throws -> R {
        
        // Meta is garanteed to be a SimpleGenericMeta of one of the Primitive types
        // or a NilMeta or a DictionaryKeyedContainerMeta or an ArrayUnkeyedContainerMeta
        // that are both GenericMetas
        
        // TODO: add nil
        
        let value: Any?
        if meta is NilMeta {
            
            value = nil
            
        } else if meta is DictionaryKeyedContainerMeta {
            
            let d = (meta as! DictionaryKeyedContainerMeta).value!
            value = try d.mapValues { return try encode($0) as R }
            
        } else if meta is ArrayUnkeyedContainerMeta {
            
            let a = (meta as! ArrayUnkeyedContainerMeta).value!
            value = try a.map { return try encode($0) as R }
            
        } else {
            
            if meta is SimpleGenericMeta<String> {
                value = (meta as! SimpleGenericMeta<String>).value!
                
            } else if meta is SimpleGenericMeta<Bool> {
                value = (meta as! SimpleGenericMeta<Bool>).value!
                
            } else if meta is SimpleGenericMeta<Float> {
                value = (meta as! SimpleGenericMeta<Float>).value!
                
            } else if meta is SimpleGenericMeta<Double> {
                value = (meta as! SimpleGenericMeta<Double>).value!
                
            } else if meta is SimpleGenericMeta<Int> {
                value = (meta as! SimpleGenericMeta<Int>).value!
                
            } else if meta is SimpleGenericMeta<UInt> {
                value = (meta as! SimpleGenericMeta<UInt>).value!
                
            } else if meta is SimpleGenericMeta<Int8> {
                value = (meta as! SimpleGenericMeta<Int8>).value!
                
            } else if meta is SimpleGenericMeta<UInt8> {
                value = (meta as! SimpleGenericMeta<UInt8>).value!
                
            } else if meta is SimpleGenericMeta<Int16> {
                value = (meta as! SimpleGenericMeta<Int16>).value!
                
            } else if meta is SimpleGenericMeta<UInt16> {
                value = (meta as! SimpleGenericMeta<UInt16>).value!
                
            } else if meta is SimpleGenericMeta<Int32> {
                value = (meta as! SimpleGenericMeta<Int32>).value!
                
            } else if meta is SimpleGenericMeta<UInt32> {
                value = (meta as! SimpleGenericMeta<UInt32>).value!
                
            } else if meta is SimpleGenericMeta<Int64> {
                value = (meta as! SimpleGenericMeta<Int64>).value!
                
            } else if meta is SimpleGenericMeta<UInt64> {
               value = (meta as! SimpleGenericMeta<UInt64>).value!
                
            } else {
                preconditionFailure("Unknown Meta")
            }
            
        }
        
        // value is eigther a primitive type
        // or Dictionary<String, primitive type>
        // or Array<primitive type>
        return try self.encodingClosure(value) as! R
        
    }
    
    public func decode<R>(_ raw: R) throws -> Meta {
        
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
