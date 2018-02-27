//
//  MetaDecoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 15.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

// decoder does pretty much the same as encoder but reversed
// it will start with a meta on stack and then will unwind this meta into an swift object

open class MetaDecoder: Decoder, MetaCoder {
    
    // MARK: - properties
    
    open var userInfo: [CodingUserInfoKey : Any]
    
    /// the CodingStorage of this decoder
    open var storage: CodingStorage
    
    /// the path of coding keys this decoder currently works on
    open var codingPath: [CodingKey]
    
    /// The translator used to get and finally translate Metas
    open let translator: Translator
    
    // MARK: initalization
    
    // TODO: chose a good default implementation for storage (also in Encoder)
    
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
        self.storage = storage
        
    }
    
    // MARK: - frontend
    
    /**
     Decodes a value of type D from the given raw value.
     
     Use this method rather than directly calling Decodable.init(from:).
     init(from:) will not detect types that are directly supported by the translator.
     
     If this decoder wasn't freshly initalized, it may throw CodingStorageErrors.
     */
    open func decode<D, Raw>(type: D.Type, from raw: Raw) throws -> D where D: Decodable {
        
        let meta = try translator.decode(raw)
        
        // will store the decoded meta at the current path
        // if it isn't directly supported by the translator
        // this current path should be the root path [],
        // but in principle it is also possible to call this somewhere else
        return try unwrap(meta, toType: type)
        
    }
    
    // MARK: - upwrap
    
    /**
     unwraps a meta to a real value using translator.unwrap and calling type.init if translator.unwrap returned nil
     
     - Parameter meta: the Meta to unwrap
     - Parameter type: The type to unwrap to
     - Parameter key: The key at which meta should be decoded. Extend coding path with this key.
     - Throws: DecodingError and CodingStorageError
     */
    open func unwrap<T: Decodable>(_ meta: Meta, toType type: T.Type, for key: CodingKey? = nil) throws -> T {
        
        // see MetaEncoder.wrap for more comments in general
        
        if key != nil { codingPath.append(key!) }
        defer{ if key != nil { codingPath.removeLast() } }
        
        // ask translator to unwrap meta to type
        do {
            
            if let directlySupported = try translator.unwrap(meta: meta, toType: type) {
                
                return directlySupported
                
            }
            
        } catch {
            
            if let decodingError = error as? DecodingError {
                
                // provide more context for DecodingErrors
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
        guard !(type.self is DirectlyCodable.Type) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Type \(type) does not match the decoded type")
            throw DecodingError.typeMismatch(type, context)
            
        }
        
        let path = self.codingPath
        try storage.store(meta: meta, at: path)
        // defer removal to restore the Decoder storage if an error was thrown in type.init
        defer{ _ = try! storage.remove(at:path) }
        
        // let type decode itself
        let value = try type.init(from: self)
        return value
        
    }
    
    private func exchangeDecodingErrorsContexts(_ decodingError: DecodingError) -> Error {
        
        // replace context's coding path
        switch decodingError {
        case .dataCorrupted(let context):
            return DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                     debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        case .keyNotFound(let key, let context):
            return DecodingError.keyNotFound(key,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        case .typeMismatch(let type, let context):
            return DecodingError.typeMismatch(type,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        case .valueNotFound(let type, let context):
            return DecodingError.valueNotFound(type,
                                               DecodingError.Context(codingPath: self.codingPath,
                                                                     debugDescription: context.debugDescription, underlyingError: context.underlyingError))
        }
        
    }
    
    // MARK: - container methods
    
    open func container<Key>(keyedBy keyType: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        
        guard self.storage[self.codingPath] is KeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Decoded value does not match the expected type.")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<Key>.self, context)
            
        }
        
        let reference = StorageReference(coder: self, at: self.codingPath)
        return KeyedDecodingContainer( MetaKeyedDecodingContainer<Key>(referencing: reference, codingPath: codingPath) )
        
    }
    
    open func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard self.storage[self.codingPath] is UnkeyedContainerMeta else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encoded type does not match with expected type.")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        let reference = StorageReference(coder: self, at: self.codingPath)
        return MetaUnkeyedDecodingContainer(referencing: reference, codingPath: codingPath)
        
    }
    
    open func singleValueContainer() -> SingleValueDecodingContainer {
        
        let reference = StorageReference(coder: self, at: self.codingPath)
        return MetaSingleValueDecodingContainer(referencing: reference, codingPath: codingPath)
        
    }
    
}
