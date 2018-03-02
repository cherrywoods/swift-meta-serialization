//
//  MetaDecoder.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

/// An Decoder that decodes from a Meta format created by a translator.
open class MetaDecoder: Decoder {
    
    // MARK: - general properties
    
    open var userInfo: [CodingUserInfoKey : Any]
    
    open var codingPath: [CodingKey]
    
    // MARK: - translator
    
    /// The translator used to get and finally translate Metas
    open let translator: Translator
    
    // MARK: - storage
    
    // use StorageAccessor construction to give lock and unlock some sence
    
    /// A StorageAccessor to this decoder's private storage
    private(set) open var storage: StorageAcessor
    
    // MARK: - initalization
    
    // TODO: remove default value of storage. Provide a default in Representation or Serialization
    
    /**
     Initalizes a new MetaDecoder with the given values.
     
     - Parameter codingPath: The coding path this decoder will start at
     - Parameter userInfo: additional information to provide context during decoding
     - Parameter translator: The translator the decoder will use to translate Metas.
     - Parameter storage: A empty CodingStorage that should be used to store metas.
     */
    public init(at codingPath: [CodingKey] = [],
                with userInfo: [CodingUserInfoKey : Any] = [:],
                translator: Translator,
                storage: CodingStorage = LinearCodingStack() ) {
        
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.translator = translator
        self.storage = StorageAcessor(with: storage)
        
    }
    
    // MARK: - upwrap
    
    /**
     Unwraps a meta to a real value using translator.unwrap and calling type.init if translator.unwrap returned nil.
     
     - Parameter meta: the Meta to unwrap, if you pass nil, the meta at this decoders current coding path will be used.
     - Parameter type: The type to unwrap to
     - Parameter key: The key at which meta should be decoded. This decoders coding path is extended with this key.
     - Throws: DecodingError and CodingStorageError
     */
    open func unwrap<T: Decodable>(_ meta: Meta? = nil,
                                   toType type: T.Type,
                                   for key: CodingKey? = nil) throws -> T {
        
        // see MetaEncoder.wrap for more comments in general
        
        if key != nil { codingPath.append(key!) }
        defer { if key != nil { codingPath.removeLast() } }
        
        // only store meta, if it isn't nil,
        // because if it is nil, we use a meta that is already stored
        let storeMeta = meta != nil
        let meta = meta ?? storage[codingPath]
        
        // ask translator to unwrap meta to type
        do {
            
            if let directlySupported = try translator.unwrap(meta: meta, toType: type) {
                
                return directlySupported
                
            }
            
        } catch {
            
            // provide more context for DecodingErrors
            if let decodingError = error as? DecodingError {
                
                throw exchangeDecodingErrorsContexts(decodingError)
                
            } else {
                
                // rethrow all other errors
                throw error
                
            }
            
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
        let path = codingPath
        if storeMeta { try storage.store(meta: meta, at: path) }
        // defer removal to restore the Decoder storage if an error was thrown in type.init
        defer { if storeMeta { _ = try! storage.remove(at:path) } }
        
        let value = try type.init(from: self)
        return value
        
    }
    
    private func exchangeDecodingErrorsContexts(_ decodingError: DecodingError) -> Error {
        
        // replace context's coding path
        switch decodingError {
        case .dataCorrupted(let context):
            return DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath,
                                                                     debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        case .keyNotFound(let key, let context):
            return DecodingError.keyNotFound(key,
                                             DecodingError.Context(codingPath: codingPath,
                                                                   debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        case .typeMismatch(let type, let context):
            return DecodingError.typeMismatch(type,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        case .valueNotFound(let type, let context):
            return DecodingError.valueNotFound(type,
                                               DecodingError.Context(codingPath: codingPath,
                                                                     debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        }
        
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
    
    // TODO: implement without ReferencingDecoder. Use regular MetaDecoder. Add new constructor.
    
    /**
     Creates a new decoder that decodes the given meta. This decoder can for example be used as super decoder.
     */
    open func decoder(for meta: Meta, at codingPath: [CodingKey]) throws -> Decoder {
        
        let newStorage = storage.fork(at: codingPath)
        
        // store meta, so it can be decoded
        try newStorage.store(meta: meta, at: codingPath)
        
        return MetaDecoder(at: codingPath,
                           with: userInfo,
                           translator: translator,
                           storage: newStorage)
        
    }
    
}
