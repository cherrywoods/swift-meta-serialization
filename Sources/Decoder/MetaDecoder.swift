//
//  MetaDecoder.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/// A `Decoder` that decodes from a `Meta` instead from a concrete format.
open class MetaDecoder: Decoder {

    // MARK: - general properties

    open let userInfo: [CodingUserInfoKey : Any]

    open var codingPath: [CodingKey]

    // MARK: - translator

    /// The `Unwrapper` used to unwrap metas
    open let unwrapper: Unwrapper

    // MARK: - storage

    /// A StorageAccessor to this decoder's private storage
    open var storage: CodingStorage

    // MARK: - initalization
    
    /**
     Initalizes a new MetaDecoder with the given values.

     - Parameter codingPath: The coding path this decoder will start at.
     - Parameter userInfo: additional information to provide context during decoding.
     - Parameter unwrapper: The `Unwrapper` the decoder will use to unwrap metas.
     - Parameter storage: A empty CodingStorage that should be used to store metas.
     */
    public init(at codingPath: [CodingKey] = [],
                with userInfo: [CodingUserInfoKey : Any] = [:],
                unwrapper: Unwrapper,
                storage: CodingStorage) {

        self.codingPath = codingPath
        self.userInfo = userInfo
        self.unwrapper = unwrapper
        self.storage = storage

    }

    // MARK: - upwrap

    /**
     Unwraps a meta to a real value using translator.unwrap and calling type.init if translator.unwrap returned nil.

     - Parameter meta: the Meta to unwrap, if you pass nil, the meta at this decoders current coding path will be used.
     - Parameter type: The type to unwrap to
     - Parameter key: The key at which meta should be decoded. This decoders coding path is extended with this key.
     - Throws: DecodingError and CodingStorageError
     */
    open func unwrap<D: Decodable>(_ meta: Meta? = nil,
                                   toType type: D.Type,
                                   for key: CodingKey? = nil) throws -> D {

        // see MetaEncoder.wrap for more comments in general

        if key != nil { codingPath.append(key!) }
        defer { if key != nil { codingPath.removeLast() } }
        let path = codingPath

        // only store meta, if it isn't nil,
        // because if it is nil, we use a meta that is already stored
        let storeMeta = meta != nil
        let meta = meta ?? storage[codingPath]

        // ask translator to unwrap meta to type
        if let directlySupported = try unwrapper.unwrap(meta: meta, toType: type, at: path) {
            
            return directlySupported
            
        }

        // ** translator does not support type natively, so it needs to decode itself **

        /*
         It is important to throw an error if type implements DirectlyDecodable
         see MetaEncoder.wrap for more information
         */
        guard !(type.self is DirectlyDecodable.Type) else {

            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: "Type \(type) does not match the decoded type")
            throw DecodingError.typeMismatch(type, context)

        }

        // do only store and remove a meta, if storeMeta is true
        if storeMeta { try storage.store(meta: meta, at: path) }
        // defer removal to restore the decoder storage if an error was thrown in type.init
        defer { if storeMeta { _ = try! storage.remove(at:path) } }

        let value = try type.init(from: self)
        return value

    }

    // MARK: - container(for: meta) methods

    /**
     Create a new KeyedDecodingContainer for the given meta, if it is a KeyedContainerMeta.

     If it is not, throw DecodingError.typeMissmatch.
     */
    open func container<Key: CodingKey>(keyedBy keyType: Key.Type, for meta: Meta, at codingPath: [CodingKey]) throws -> KeyedDecodingContainer<Key> {

        guard let keyedMeta = meta as? KeyedContainerMeta else {

            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded value does not match the expected type.")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<Key>.self, context)

        }

        return KeyedDecodingContainer( MetaKeyedDecodingContainer<Key>(for: keyedMeta, at: codingPath, decoder: self) )

    }

    /**
     Create a new UnkeyedDecodingContainer for the given meta, if it is a UnkeyedContainerMeta.

     If it is not, throw DecodingError.typeMissmatch.
     */
    open func unkeyedContainer(for meta: Meta, at codingPath: [CodingKey]) throws -> UnkeyedDecodingContainer {

        guard let unkeyedMeta = meta as? UnkeyedContainerMeta else {

            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded value does not match the expected type.")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)

        }

        return MetaUnkeyedDecodingContainer(for: unkeyedMeta, at: codingPath, decoder: self)

    }

    /**
     Create a new SingleValueDecodingContainer for the given meta.
     */
    open func singleValueContainer(for meta: Meta, at codingPath: [CodingKey]) throws -> SingleValueDecodingContainer {

        return MetaSingleValueDecodingContainer(for: meta, at: codingPath, decoder: self)

    }

    // MARK: - super decoder

    /**
     Creates a new decoder that decodes the given meta. This decoder can for example be used as super decoder.
     */
    open func decoder(for meta: Meta, at codingPath: [CodingKey]) throws -> Decoder {

        let newStorage = storage.fork(at: codingPath)

        // store meta, so it can be decoded
        try newStorage.store(meta: meta, at: codingPath)

        return MetaDecoder(at: codingPath,
                           with: userInfo,
                           unwrapper: unwrapper,
                           storage: newStorage)

    }

}
