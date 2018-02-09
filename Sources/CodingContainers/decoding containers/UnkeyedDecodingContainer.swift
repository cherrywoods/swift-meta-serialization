//
//  UnkeyedDecodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 20.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 Manages a UnkeyedContainerMeta
 */
open class MetaUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    
    private(set) open var reference: Reference
    open var referencedMeta: UnkeyedContainerMeta {
        get {
            return reference.element as! UnkeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    open var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    // MARK: - container methods
    
    open var count: Int? {
        return referencedMeta.count
    }
    
    open var isAtEnd: Bool {
        // if the number of elements is unknown
        // one can't say, if there are still more elements...
        return self.count != nil && self.currentIndex >= self.count!
    }
    
    // UnkeyedContainerMeta is required to start at 0 and end at count-1
    public var currentIndex: Int = 0
    
    // MARK: - decoding
    
    open func decodeNil() throws -> Bool {
        
        // first check whether the container still has an element
        guard let subMeta = referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "UnkeyedContainer is at end.")
            throw DecodingError.valueNotFound(Any?.self, context)
        }
        
        let isNil = subMeta is NilMetaProtocol
        // as documentation says, we should only increment currentValue,
        // if the encoded value is nil
        if isNil { self.currentIndex += 1 }
        return isNil
        
    }
    
    open func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        // first check whether the container still has an element
        guard let subMeta = referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "UnkeyedContainer is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
        
        // the coding path needs to be extended, because unwrap(meta) may throw an error
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: currentIndex)!)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        let value: T = try (self.reference.coder as! MetaDecoder).unwrap(subMeta, toType: type)
        
        // now we decoded a value with success,
        // therefor we can increment currentIndex
        self.currentIndex += 1
        
        return value
        
    }
    
    // MARK: - nested container
    
    open func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let keyedSubMeta = subMeta as? KeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<NestedKey>.self, context)
        }
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: keyedSubMeta)
        
        return KeyedDecodingContainer(
            MetaKeyedDecodingContainer<NestedKey>(referencing: nestedReference)
        )
        
    }
    
    open func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let unkeyedSubMeta = subMeta as? UnkeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: unkeyedSubMeta)
        
        return  MetaUnkeyedDecodingContainer(referencing: nestedReference)
        
    }
    
    // MARK: - super encoder
    
    open func superDecoder() throws -> Decoder {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        defer{ try! reference.coder.stack.removeLastCodingKey() }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(Decoder.self, context)
        }
        
        let referenceToOwnMeta = UnkeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, index: currentIndex)
        let decoder = ReferencingMetaDecoder(referencing: referenceToOwnMeta, meta: subMeta)
        
        self.currentIndex += 1
        return decoder
        
    }
    
}
