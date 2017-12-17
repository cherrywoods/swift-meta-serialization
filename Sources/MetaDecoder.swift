//
//  MetaDecoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 15.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

// decoder does pretty much the same as encoder but reversely
// it will start with a meta on stack and then will unwind this meta into an swift object

open class MetaDecoder: Decoder, MetaCoder {
    
    public var userInfo: [CodingUserInfoKey : Any]
    
    /// the CodingStack of this decoder
    public var stack: CodingStack
    
    public var codingPath: [CodingKey] {
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
    public func decode<D>(type: D.Type) throws -> D? where D: Decodable {
        
        // decode over unwrap function
        // this will keep D from decoding itself,
        // if it is supported by translator
        
        // return the unwrapped topContainer
        
        guard let meta = stack.first else {
            // if stack has somehow no first element:
            return nil
        }
        
        return try unwrap(meta) as D
        
    }
    
    // MARK: - translator
    
    /// The translator used to get and finally translate Metas
    public let translator: Translator
    
    
    
    /// wraps a meta into a decodable value
    public func unwrap<T: Decodable>(_ meta: Meta) throws -> T {
        
        // single value containers may not redecode their values with new containers,
        // so their values need to be supported directly by the translator
        // for more details see MetaEncoder
        
        if let directlySupported = try translator.unwrap(meta: meta) as T? {
            return directlySupported
        }
        
        // translator does not support T natively, so it needs to decode itself
        
        guard self.stack.mayPushNewMeta else {
            // this error is thrown, if an entitys type, that requested a single value container
            // was not supported natively by the translator
            throw DecodingError.typeMismatch(T.self,
                                             DecodingError.Context(codingPath: self.codingPath, debugDescription: "Type \(T.self) is not supported by this serialization framework."))
        }
        
        // now it is sure, that stack will accept a new meta
        try self.stack.push(meta: meta)
        let value = try T(from: self)
        _ = try self.stack.pop()
        
        return value
        
    }
    
    // MARK: initalization
    
    /**
     Initalizes a new MetaDecoder with the given values.
     
     This initalizer will fail, if the first step decoding of raw by translator produces an error.
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
        self.stack = CodingStack(at: codingPath, with: .pathMissesMeta)
        try! self.stack.push(meta: meta) // since stack is inited with .pathMissesMeta, this will not throw
    }
    
    // MARK: - container methods
    
    public func container<Key>(keyedBy keyType: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        
        guard self.stack.last is KeyedContainerMeta else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encoded type dos not match with expected type.")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<Key>.self, context)
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return KeyedDecodingContainer(
            MetaKeyedDecodingContainer<Key>(referencing: referencing)
        )
        
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard self.stack.last is UnkeyedContainerMeta else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encoded type dos not match with expected type.")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return MetaUnkeyedDecodingContainer(referencing: referencing)
        
    }
    
    public func singleValueContainer() -> SingleValueDecodingContainer {
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return MetaSingleValueDecodingContainer(referencing: referencing)
        
    }
    
}

/// Used by superEncoder() in MetaKeyedEncodingContainer and MetaUnkeyedEncodingContainer
public class ReferencingMetaDecoder: MetaDecoder {
    
    private var reference: ContainerReference
    
    // MARK: initalization
    
    /**
     Initalizes a new SubEncoder with the given values.
     - Parameter referening: A ContainerReference to the (encoding or decoding) container this referencing encoder will reference
     - Parameter meta: The meta that should be decoded by this decoder
     */
    init(referencing reference: ContainerReference, meta: Meta) {
        
        self.reference = reference
        super.init(at: reference.coder.codingPath, translator: reference.coder.translator, topContainer: meta)
        
    }
    
    // MARK: - deinitalization
    
    // flushes the meta object on stack to reference
    // this can only be done at this point, because before the meta object may be a copy-type (struct) and therefor not ready until now
    deinit {
        
        precondition(stack.count <= 1, "ReferencingEncoder deinitalized holding multiple containers")
        
        // if there's no element on the stack, do nothing
        if let meta = stack.first {
            
            reference.insert(meta)
            
        }
        
    }
    
}
