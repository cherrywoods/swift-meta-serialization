//
//  MetaDecoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 15.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

// decoder does pretty much the same as encoder but reversely
// it will start with a meta on stack and then will unwind this meta into an swift object

open class MetaDecoder: Decoder, MetaCoder {
    
    public var userInfo: [CodingUserInfoKey : Any]
    
    /// the CodingStack of this decoder
    public var stack: CodingStack
    
    open var codingPath: [CodingKey] {
        return stack.codingPath
    }
    
    // MARK: - front end
    
    /**
     Decodes a value of type D
     
     Use this method rather than directly calling init(from:).
     init(from:) will not detect types in the first place
     that are directly supported by the translator.
     Therefor some actually decodable values would fail to be decoded.
     
     If this decoder is freshly initalized, this function will return a non-nil value.
     
     - Returns: A new decoded value of type D or nil, if this decoder is not in an appropiate state to decode a value.
     */
    open func decode<D>(type: D.Type) throws -> D? where D: Decodable {
        
        // decode similar to unwrap
        // this will keep D from decoding itself,
        // if it is supported by translator
        
        // return the unwrapped topContainer
        
        guard let meta = stack.first else {
            // if stack has somehow no element:
            return nil
        }
        
        // in diffrence to MetaEncoder,
        // we may not simply call unwrap here
        // because our meta is allready at the stack
        
        // therefor we "manually" check whether translator
        // supportes meta directly
        
        if let directlySupported = try translator.unwrap(meta: meta, toType: type) as D? {
            return directlySupported
        }
        
        // and if it isn't directly supported, we call
        return try type.init(from: self) // and let D decode itself
        
    }
    
    // MARK: - translator
    
    /// The translator used to get and finally translate Metas
    open let translator: Translator
    
    /**
     wraps a meta into a decodable value
     */
    open func unwrap<T: Decodable>(_ meta: Meta, toType type: T.Type) throws -> T {
        
        // single value containers can now decode more complex values
        // see MetaEncoder for more details
        // also see MetaEncoder in general for more comments
        
        do {
            
            if let directlySupported = try translator.unwrap(meta: meta, toType: type) as T? {
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
        
        // ** translator does not support T natively, so it needs to decode itself **
        
        /*
         It is important to throw an error if type implements DirectlyDecodable
         see MetaEncoder.wrap for more information
         */
        guard !(type.self is DirectlyCodable.Type) else {
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Type \(type) does not match the decoded type")
            throw DecodingError.typeMismatch(type, context)
        }
        
        try self.stack.push(meta: meta)
        // defer pop to restore the Decoder stack if an error was thrown in type.init
        defer{ _ = try! self.stack.pop() }
        
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
    
    // MARK: initalization
    
    /**
     Initalizes a new MetaDecoder with the given values.
     
     This initalizer decodes raw and will throw an error if decoding fails
     - Parameter at: The coding path this decoder will start at
     - Parameter withUserInfo: additional inforamtion for the user
     - Parameter translator: The translator the encoder will use to translate Metas.
     - Parameter raw: The raw data, that should be decoded with this decoder.
     */
    public convenience init<Raw>(at codingPath: [CodingKey] = [],
                            withUserInfo userInfo: [CodingUserInfoKey : Any] = [:],
                            translator: Translator,
                            raw: Raw) throws {
        
        let decodedMeta = try translator.decode(raw)
        self.init(at: codingPath, withUserInfo: userInfo, translator: translator, topContainer: decodedMeta)
        
    }
    
    /**
     Initalizes a new MetaDecoder with the given values.
     
     This constructor uses StrictCodingStack as CodingStack implementation.
     - Parameter at: The coding path this decoder will start at
     - Parameter withUserInfo: additional inforamtion for the user
     - Parameter translator: The translator the decoder will use to translate Metas.
     - Parameter topContainer: the halfway decoded meta, that should be decoded in this decoder.
     */
    public init(at codingPath: [CodingKey] = [],
                withUserInfo userInfo: [CodingUserInfoKey : Any] = [:],
                translator: Translator,
                topContainer meta: Meta) {
        self.userInfo = userInfo
        self.translator = translator
        self.stack = StrictCodingStack(at: codingPath)
        try! self.stack.push(meta: meta) // since stack is inited with .pathMissesMeta, this will not throw
    }
    
    // MARK: - container methods
    
    open func container<Key>(keyedBy keyType: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        
        guard self.stack.last is KeyedContainerMeta else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encoded type does not match with expected type.")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<Key>.self, context)
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return KeyedDecodingContainer(
            MetaKeyedDecodingContainer<Key>(referencing: referencing)
        )
        
    }
    
    open func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard self.stack.last is UnkeyedContainerMeta else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encoded type does not match with expected type.")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return MetaUnkeyedDecodingContainer(referencing: referencing)
        
    }
    
    open func singleValueContainer() -> SingleValueDecodingContainer {
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return MetaSingleValueDecodingContainer(referencing: referencing)
        
    }
    
}

/// Used by superDecoder() in MetaKeyedDecodingContainer and MetaUnkeyedDecodingContainer
public class ReferencingMetaDecoder: MetaDecoder {
    
    private var reference: ContainerReference
    
    // MARK: initalization
    
    /**
     Initalizes a new SubEncoder with the given values.
     
     This constructor uses StrictCodingStack as CodingStack implementation.
     - Parameter referening: A ContainerReference to the (encoding or decoding) container this referencing encoder will reference
     - Parameter meta: The meta that should be decoded by this decoder
     */
    public init(referencing reference: ContainerReference, meta: Meta) {
        
        self.reference = reference
        super.init(at: reference.coder.codingPath, translator: reference.coder.translator, topContainer: meta)
        
    }
    
    // Note: referencing Decoders should not flush back their results to the reference they have
    
}
