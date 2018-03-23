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

/// An `Encoder` that constucts a `Meta` instead of encoding to a concrete format.
open class MetaEncoder: Encoder {

    // MARK: - general properties

    open let userInfo: [CodingUserInfoKey : Any]

    open var codingPath: [CodingKey]

    // MARK: - translator

    /// The translator used to get and finally translate Metas
    open let metaSupplier: MetaSupplier

    // MARK: - storage

    /// This encoder's storage
    open var storage: CodingStorage

    // MARK: - initalizers

    /**
     Initalizes a new MetaEncoder with the given values.

     - Parameter codingPath: The coding path this decoder will start at
     - Parameter userInfo: additional information to provide context during decoding
     - Parameter translator: The translator the decoder will use to translate Metas.
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
     Wraps a value to a meta using translator.wrappingMeta and calling value.encode if translator.wrappingMeta returned nil.

     If value conforms to DirectlyEncdable, or is an Int, Int8, Int16, Int32, Int64, UInt, UInt8, UInt16, UInt32, UInt64, Float, Double, Bool or String and
     not supported directly by translator (this means translator.wrappingMeta(for: value) returns nil, this method throws EncodingError.invalidValue. This is required, because otherwise, these types would endlessly try to encode themselves into single value containers.

     - Parameter value: The value to wrap
     - Parameter key: The key at which vaue should be encoded. This decoders coding path is extended with this key.
     - Throws: EncodingError and CodingStorageError
     */
    open func wrap<E>(_ value: E, at key: CodingKey? = nil) throws -> Meta where E: Encodable {

        if key != nil { codingPath.append(key!) }
        defer{ if key != nil { codingPath.removeLast() } }
        let path = codingPath

        // check whether translator supports value directly
        if let newMeta = try metaSupplier.wrap(for: value, at: path) {

            // meta's value should be already set by translator
            return newMeta

        }

        // ** now the value's type is not supported natively by translator **

        /*
         Need to throw an error, if value is an Int, Int8, Int16, Int32, Int64, UInt, UInt8, UInt16, UInt32, UInt64, Float, Double, Bool or String
         but isn't supported by the translator,
         because if not, an endless callback would follow
         see Foundation Primitive Codables.swift for more information.

         The same applies for DirectlyEncodable.

         We also need to throw an error, if value is an GenericNil
         instance, because if we did not, nil values would encode
         as empty containers.

         All this is archieved by checking if value is DirectlyEncodable.
         All foundation's "primitive codables" (listed above) and GenericNil too are extended
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
            _ = try? storage.remove(at: path)
            throw error
            
        }

        // if value requests no container,
        // we are promted by the documention of Encodable to encode an empty keyed container
        return try storage.remove(at: path) ?? metaSupplier.keyedContainerMeta()

    }

    // MARK: - container(referencing:) methods

    /**
     Returns a new KeyedEncodingContainer referencing reference.

     - Parameter keyType: The key type of the KeyedEncodingContainer that should be returned.
     - Parameter reference: A reference to which the returned container should point to.
     - Parameter codingPath: The coding path the returned container should have.
     - Parameter createNewContainer: Whether to create a new contaienr and set reference.meta to it, or not. Default is yes.
     */
    open func container<Key: CodingKey>(keyedBy keyType: Key.Type, referencing reference: Reference, at codingPath: [CodingKey], createNewContainer: Bool = true) -> KeyedEncodingContainer<Key> {

        if createNewContainer {

            var reference = reference
            reference.meta = metaSupplier.keyedContainerMeta()

        }

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
    open func unkeyedContainer(referencing reference: Reference, at codingPath: [CodingKey], createNewContainer: Bool = true) -> UnkeyedEncodingContainer {

        if createNewContainer {

            var reference = reference
            reference.meta = metaSupplier.unkeyedContainerMeta()

        }

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

        return MetaEncoder(at: codingPath,
                           with: userInfo,
                           metaSupplier: metaSupplier,
                           storage: referencingStorage)

    }

}
