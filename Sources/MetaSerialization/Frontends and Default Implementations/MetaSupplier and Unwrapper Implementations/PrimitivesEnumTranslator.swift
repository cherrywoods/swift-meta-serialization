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

/**
 A implementation of `MetaSupplier` and `Unwrapper` that gets Metas out of your way, so you will only have to work with Arrays, Dictionarys and the Primitive types you pass to it.
 */
public struct PrimitivesEnumTranslator: MetaSupplier, Unwrapper {
    
    let primitives: Set<Primitive>
    let useOrderedKeyedContainer: Bool
    
    /**
     Create a new PrimitivesEnumTranslator.
     - Parameter primitives: A set of primitives types you can handle directly. The default value is Primitive.all.
     - Parameter maintainOrder: Whether to use a keyed container that maintains the insertion order. If true, the keyed containers you receive are instances of OrderedKeyedContainer. If false, they are simple Dictionaries. Unkeyed containers always maintain insertion order.
     - Note: You have to pass Primitive.all, if you wan't do be able to handle all of swifts standard types.
     */
    public init( primitives: Set<Primitive> = Primitive.all, maintainOrder useOrderedKeyedContainer: Bool = false) {
        
        self.primitives = primitives
        self.useOrderedKeyedContainer = useOrderedKeyedContainer
        
    }
    
    // we use this translator as backend, but we additionaly check if the type is contained in primitives
    let protocolTranslator: PrimitivesProtocolTranslator<any PrimitivesEnumTranslatorPrimitives, any PrimitivesEnumTranslatorPrimitives.Type> = PrimitivesProtocolTranslator<PrimitivesEnumTranslatorPrimitives, PrimitivesEnumTranslatorPrimitives.Type>()
    
    public func wrap<T>(_ value: T, for encoder: MetaEncoder) throws -> Meta? {
        
        guard let typeAsPrimitive = Primitive(from: T.self) else {
            // don't even need to try for non primitives
            return nil
        }
        
        guard primitives.contains(typeAsPrimitive) else {
            return nil
        }
        
        return try protocolTranslator.wrap(value, for: encoder)
        
    }
    
    public func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? {
        
        guard let typeAsPrimitive = Primitive(from: type) else {
            // don't even need to try for non primitives
            return nil
        }
        
        guard primitives.contains(typeAsPrimitive) else {
            return nil
        }
        
        return try protocolTranslator.unwrap(meta: meta, toType: type, for: decoder)
        
    }

    public func keyedContainerMeta() -> any EncodingKeyedContainerMeta {
        if self.useOrderedKeyedContainer {
            return OrderedKeyedContainer()
        } else {
            return Dictionary<String, Meta>()
        }
    }
    
}
