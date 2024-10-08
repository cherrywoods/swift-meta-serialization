//
//  MetaDecoder.swift
//  MetaSerialization
//
//  Copyright 2018-2024 cherrywoods
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

/// A `Decoder` that decodes from a Meta instead from a concrete format.
open class MetaDecoder: Decoder {

    // MARK: - general properties

    public let userInfo: [CodingUserInfoKey : Any]

    open var codingPath: [CodingKey]

    // MARK: - translator

    /// The `Unwrapper` used to unwrap metas
    public let unwrapper: Unwrapper

    // MARK: - storage

    /// Access to to this decoder's private storage
    open var storage: CodingStorage

    // MARK: - initalization
    
    /**
     Initalizes a new MetaDecoder with the given values.

     - Parameter codingPath: The coding path this decoder will start at.
     - Parameter userInfo: additional information to provide context during decoding.
     - Parameter unwrapper: The `Unwrapper` the decoder will use to unwrap Metas.
     - Parameter storage: A empty CodingStorage that should be used to store Metas.
     */
    public init(at codingPath: [CodingKey] = [],
                with userInfo: [CodingUserInfoKey : Any] = [:],
                unwrapper: Unwrapper,
                storage: CodingStorage = LinearCodingStack()) {

        self.codingPath = codingPath
        self.userInfo = userInfo
        self.unwrapper = unwrapper
        self.storage = storage

    }

    // MARK: - upwrap

    /**
     Unwraps a meta to a proper Swift value using `unwrapper.unwrap` and calling `type.init(from:)` if `unwrapper.unwrap` returned nil.

     - Parameter meta: the Meta to unwrap. If you pass nil, the Meta at this decoders current coding path is deconded.
     - Parameter type: The Swift type to unwrap to.
     - Parameter key: The key at which the Meta is to be decoded. This decoders coding path is extended with this key.
     - Throws: DecodingError and CodingStorageError
     */
    open func unwrap<D: Decodable>(_ meta: Meta? = nil,
                                   toType type: D.Type,
                                   for key: CodingKey? = nil) throws -> D {

        // see MetaEncoder.wrap for more comments in general

        if key != nil { codingPath.append(key!) }
        defer { if key != nil { codingPath.removeLast() } }
        let path = codingPath

        let storeMeta = meta != nil
        let meta = meta ?? storage[codingPath]

        if storeMeta { try storage.store(meta: meta, at: path) }
        // defer removal to restore the decoder storage if an error was thrown in type.init or in unwrap
        defer { if storeMeta { _ = try! storage.remove(at:path) } }

        // already having stored before unwrap makes it possible to use container methods in unwrap.
        // however with this store, `decoder.decode` can not be called in `unwrapper.unwrap`.
        
        // ask unwrapper to unwrap meta to type
        if let directlySupported = try unwrapper.unwrap(meta: meta, toType: type, for: self) {
            
            return directlySupported
            
        }

        // ** unwrapper does not support type natively, so it needs to decode itself **

        /*
         It is important to throw an error if type implements DirectlyDecodable
         to avoid endless recursion,
         see MetaEncoder.wrap for more information
         */
        guard !(type.self is DirectlyDecodable.Type) else {

            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Type \(type) does not match the encoded type")
            throw DecodingError.typeMismatch(type, context)

        }

        let value = try type.init(from: self)
        return value

    }

    // MARK: - nil values
    
    /// Checks whether the given Meta represents a NilMeta. Tries to dynamically unwrap Meta if specified.
    open func representsNil(meta passedMeta: Meta) -> Bool {
        
        // also unwrap nil requests
        let meta = unwrapper.unwrap(meta: passedMeta, toType: NilMeta.self, for: self) ?? passedMeta
        return meta is NilMeta
        
    }
    
    // MARK: - container(for: meta) methods

    /**
     Create a new KeyedDecodingContainer for the given Meta, if it is a DecodingKeyedContainerMeta.

     If it is not, throw DecodingError.typeMissmatch.
     */
    public func container<Key: CodingKey>(keyedBy keyType: Key.Type, for passedMeta: Meta, at codingPath: [CodingKey]) throws -> KeyedDecodingContainer<Key> {
        
        // also unwrap containers
        let meta = try unwrapper.unwrap(meta: passedMeta, toType: DecodingKeyedContainerMeta.self, for: self) ?? passedMeta
        
        guard let keyedMeta = meta as? DecodingKeyedContainerMeta else {

            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded value does not match the expected container type.")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<Key>.self, context)

        }

        return try decodingContainer(keyedBy: keyType, for: keyedMeta, at: codingPath)
        
    }

    open func decodingContainer<Key: CodingKey>(keyedBy keyType: Key.Type, for keyedMeta: DecodingKeyedContainerMeta, at codingPath: [CodingKey]) throws -> KeyedDecodingContainer<Key> {
        
        return KeyedDecodingContainer( MetaKeyedDecodingContainer<Key>(for: keyedMeta, at: codingPath, decoder: self) )

    }
    
    /**
     Create a new UnkeyedDecodingContainer for the given Meta, if it is a DecodingUnkeyedContainerMeta.

     If it is not, throw DecodingError.typeMissmatch.
     */
    public func unkeyedContainer(for passedMeta: Meta, at codingPath: [CodingKey]) throws -> UnkeyedDecodingContainer {

        let meta = try unwrapper.unwrap(meta: passedMeta, toType: DecodingUnkeyedContainerMeta.self, for: self) ?? passedMeta
        
        guard let unkeyedMeta = meta as? DecodingUnkeyedContainerMeta else {

            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded value does not match the expected container type.")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)

        }

        return try unkeyedDecodingContainer(for: unkeyedMeta, at: codingPath)
        
    }

    open func unkeyedDecodingContainer(for unkeyedMeta: DecodingUnkeyedContainerMeta, at codingPath: [CodingKey]) throws -> UnkeyedDecodingContainer {
        
        return MetaUnkeyedDecodingContainer(for: unkeyedMeta, at: codingPath, decoder: self)

    }
    
    /**
     Create a new SingleValueDecodingContainer for the given Meta.
     */
    open func singleValueContainer(for meta: Meta, at codingPath: [CodingKey]) throws -> SingleValueDecodingContainer {

        return MetaSingleValueDecodingContainer(for: meta, at: codingPath, decoder: self)

    }

    // MARK: - super decoder

    /**
     Creates a new decoder that decodes the given Meta. This decoder can for example be used as super decoder.
     */
    open func decoder(for meta: Meta, at codingPath: [CodingKey]) throws -> Decoder {

        let newStorage = storage.fork(at: codingPath)

        // store meta, so it can be decoded
        try newStorage.store(meta: meta, at: codingPath)

        return try decoderImplementation(storage: newStorage, at: codingPath)

    }

    /**
     Creates a new decoder with the given storage.
     
     This method is used as delegate for decoder(for:, at:)'s default implementation.
     */
    open func decoderImplementation(storage: CodingStorage, at codingPath: [CodingKey] ) throws -> Decoder {
        
        return MetaDecoder(at: codingPath,
                           with: userInfo,
                           unwrapper: unwrapper,
                           storage: storage)
        
    }
    
}
