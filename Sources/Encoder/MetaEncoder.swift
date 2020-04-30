//
//  MetaCoder.swift
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
 An `Encoder` that constucts a `Meta` instead of encoding to a concrete format.
 
 Use the `encode` method of a MetaEncoder to encode a value into a inbetween (meta) representation. You can specify details of this meta representation using the `MetaSupplier`.
 
 This encoder does not support conditional encoding using the method `encodeConditional` on `KeyedEncodingContainer` and `UnkeyedEncodingContainer` instances. Use of these methods will fallback to unconditional encoding.  Please use the `ConditionalEncodingMetaEncoder` subclass, if you require conditional encoding capabilities.
 */
open class MetaEncoder: Encoder {

    // MARK: - general properties

    public let userInfo: [CodingUserInfoKey : Any]

    open var codingPath: [CodingKey]

    // MARK: - translator

    /// The translator used to get and finally translate Metas
    public let metaSupplier: MetaSupplier

    // MARK: - storage

    /// This encoder's storage
    open var storage: CodingStorage

    // MARK: - initalizers

    /**
     Initalizes a new MetaEncoder with the given values.

     - Parameter codingPath: The coding path this encoder will start at
     - Parameter userInfo: additional information to provide context during encoding
     - Parameter translator: The translator the encoder will use to translate Metas.
     - Parameter storage: A empty CodingStorage that should be used to store metas.
     */
    public init(at codingPath: [CodingKey] = [],
                with userInfo: [CodingUserInfoKey : Any] = [:],
                metaSupplier: MetaSupplier,
                storage: CodingStorage = LinearCodingStack() ) {

        self.codingPath = codingPath
        self.userInfo = userInfo
        self.metaSupplier = metaSupplier
        self.storage = storage

    }

    // MARK: - wrap

    /**
     Wraps a value to a meta using `metaSupplier.wrap` and calling `value.encode` if `metaSupplier.wrap` returned nil.

     If value conforms to `DirectlyEncodable`, or is an `Int`, `Int8`, `Int16`, `Int32`, `Int64`, `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`, `Float`, `Double`, `Bool` or `String` and
     not supported directly by meta supplier (this means `metaSupplier.wrap` returns nil), this method throws `EncodingError.invalidValue`. This is required because otherwise, these types would endlessly try to encode themselves into single value containers.

     - Parameter value: The value to wrap
     - Parameter key: The key at which `value` should be encoded. This encoders coding path is extended with this key. If key is nil, the coding path isn't extended.
     - Throws: EncodingError and CodingStorageError
     */
    open func wrap<E: Encodable>(_ value: E, at key: CodingKey? = nil) throws -> Meta {

        if key != nil { codingPath.append(key!) }
        defer{ if key != nil { codingPath.removeLast() } }
        let path = codingPath

        // check whether translator supports value directly
        if let newMeta = try metaSupplier.wrap(value, for: self) {

            // meta's value should be already set by translator
            return newMeta

        }

        // ** now the value's type is not supported natively by metaSupplier **

        /*
         Need to throw an error, if value is an Int, Int8, Int16, Int32, Int64, UInt, UInt8, UInt16, UInt32, UInt64, Float, Double, Bool or String
         but isn't supported by the translator,
         because if not, an endless callback would follow
         see Foundation Primitive Codables.swift for more information.

         The same applies for DirectlyEncodable.

         We also need to throw an error, if value is an NilMarker
         instance, because if we did not, nil values would encode
         as empty containers.

         All this is archieved by checking if value is DirectlyEncodable.
         All foundation's "primitive codables" (listed above) and NilMarker too are extended
         to implement DirectlyCodable.
         */

        guard !(value is DirectlyEncodable) else {

            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "DirectlyEncodable value \(String(describing: value)) was not accepted by the Translator implementation.")
            throw EncodingError.invalidValue(value, context)

        }

        try storage.storePlaceholder(at: path)
        
        do {
            
            // let value encode itself to this encoder
            try value.encode(to: self)
            
        } catch {
            
            // remove the placeholder that was stored at the path
            // (or any incomplete metas)
            // this makes it possible to encode another value, if an error was thrown
            _ = ((try? storage.remove(at: path)) as Meta??)
            throw error
            
        }

        // if value requests no container,
        // we are promted by the documention of Encodable to encode an empty keyed container
        return try storage.remove(at: path) ?? metaSupplier.keyedContainerMeta()

    }
    
    /**
     Wraps an object that is conditionally encoded using `encodeConditional` using an KeyedEncodingContainer or UnkeyedEncodingContainer.
     
     The `MetaSupplier` is asked to provide a meta for this task using `conditionalEncodingMeta(for:)`. If it returns nil, `wrap` is called to encode `object` unconditionally, mimicking the behavior of the default implementation of `encodeConditional` of `KeyedEncodingContainer` and `UnkeyedEncodingContainer`.
     
     - Throws: all errors `wrap` throws are rethrown.
     - Note: This method has no variant without `at` since only encoding containers make use of it.
     */
    open func wrapConditional<E: Encodable>(_ object: E, at key: CodingKey) throws -> Meta where E : AnyObject {
        
        guard let newMeta = try metaSupplier.conditionalEncodingMeta(for: object) else {
            // encode unconditionally
            return try wrap(object, at: key)
        }
        
        return newMeta
        
    }
    
    // MARK: - container(referencing:) methods

    /**
     Returns a new KeyedEncodingContainer referencing reference.
     
     - Parameter keyType: The key type of the KeyedEncodingContainer that should be returned.
     - Parameter reference: A reference to which the returned container should point to.
     - Parameter codingPath: The coding path the returned container should have.
     - Parameter createNewContainer: Whether to create a new contaienr and set reference.meta to it, or not. Default is yes.
     */
    public func container<Key: CodingKey>(keyedBy keyType: Key.Type, referencing reference: Reference, at codingPath: [CodingKey], createNewContainer: Bool = true) -> KeyedEncodingContainer<Key> {
        
        if createNewContainer {
            
            var reference = reference
            reference.meta = metaSupplier.keyedContainerMeta()
            
        }
        
        return encodingContainer(keyedBy: keyType, referencing: reference, at: codingPath)
        
    }
    
    /**
     Returns a new KeyedEncodingContainer referencing reference.
     
     This method serves as delegate for container(keyedBy:, referencing, at:, createNewContainer).
     
     - Parameter keyType: The key type of the KeyedEncodingContainer that should be returned.
     - Parameter reference: A reference to which the returned container should point to.
     - Parameter codingPath: The coding path the returned container should have.
     */
    open func encodingContainer<Key: CodingKey>(keyedBy keyType: Key.Type, referencing reference: Reference, at codingPath: [CodingKey]) -> KeyedEncodingContainer<Key> {
        
        return KeyedEncodingContainer( MetaKeyedEncodingContainer<Key>(referencing: reference,
                                                                       at: codingPath,
                                                                       encoder: self) )

    }
    
    /**
     Returns a new UnkeyedEncodingContainer referencing reference.
     
     - Parameter reference: A reference to which the returned container should point to.
     - Parameter codingPath: The coding path the returned container should have.
     - Parameter createNewContainer: Whether to create a new contaienr and set reference.meta to it. Default is true.
     */
    public func unkeyedContainer(referencing reference: Reference, at codingPath: [CodingKey], createNewContainer: Bool = true) -> UnkeyedEncodingContainer {
        
        if createNewContainer {
            
            var reference = reference
            reference.meta = metaSupplier.unkeyedContainerMeta()
            
        }
        
        return unkeyedEncodingContainer(referencing: reference, at: codingPath)
        
    }

    /**
     Returns a new UnkeyedEncodingContainer referencing reference.
     
     This method serves as delegate for container(keyedBy:, referencing, at:, createNewContainer).
     
     - Parameter reference: A reference to which the returned container should point to.
     - Parameter codingPath: The coding path the returned container should have.
     */
    open func unkeyedEncodingContainer(referencing reference: Reference, at codingPath: [CodingKey]) -> UnkeyedEncodingContainer {
        
        return MetaUnkeyedEncodingContainer(referencing: reference,
                                            at: codingPath,
                                            encoder: self)

    }
    
    /**
     Returns a new MetaKeyedEncodingContainer referencing reference.

     - Parameter reference: A reference to which the returned container should point to.
     - Parameter codingPath: The coding path the returned container should have.
     */
    open func singleValueContainer(referencing reference: Reference, at codingPath: [CodingKey]) -> SingleValueEncodingContainer {

        return MetaSingleValueEncodingContainer(referencing: reference,
                                                at: codingPath,
                                                encoder: self)

    }

    // MARK: - superEncoder

    /**
     Creates a new encoder that encodes to the given reference. This encoder can for example be used as super encoder.
     */
    open func encoder(referencing reference: Reference, at codingPath: [CodingKey]) -> Encoder {

        let referencingStorage = ReferencingCodingStorage(referencing: reference,
                                                          delegatingTo: storage.fork(at: codingPath),
                                                          at: codingPath)

        return encoderImplementation(storage: referencingStorage, at: codingPath)
        
    }

    /**
     Creates a new encoder with the given storage.
     
     This method serves as delegate for encoder(referencing:, at:)'s default implementation.
     */
    open func encoderImplementation(storage: CodingStorage, at codingPath: [CodingKey] ) -> Encoder {
        
        return MetaEncoder(at: codingPath,
                           with: userInfo,
                           metaSupplier: metaSupplier,
                           storage: storage)

    }
    
}
