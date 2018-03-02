//
//  UnkeyedDecodingContainer.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 Manages a UnkeyedContainerMeta
 */
open class MetaUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    
    /**
     This MetaUnkeyedDecodingContainer's meta.
     */
    open let meta: UnkeyedContainerMeta
    
    /**
     The decoder that created this container.
     
     Decoding, creating new containers and creating super decoders is delegated to it.
     */
    open let decoder: MetaDecoder
    
    open let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(for meta: UnkeyedContainerMeta, at codingPath: [CodingKey], decoder: MetaDecoder) {
        
        self.meta = meta
        self.codingPath = codingPath
        self.decoder = decoder
        
    }
    
    // MARK: - container methods

    open var count: Int? {
        return meta.count
    }

    open var isAtEnd: Bool {
        // if the number of elements is unknown
        // no one can say, if there are still more elements...
        return self.count != nil && self.currentIndex >= self.count!
    }

    // UnkeyedContainerMeta is required to start at 0 and end at count-1
    
    open var currentIndex: Int = 0

    // MARK: - decoding

    open func decodeNil() throws -> Bool {

        let isNil = try accessMetaAtCurrentIndex() is NilMetaProtocol
        
        // as documentation says, we should only increment currentValue,
        // if the encoded value is nil
        if isNil { self.currentIndex += 1 }
        
        return isNil

    }

    open func decode<T>(_ type: T.Type) throws -> T where T : Decodable {

        let subMeta = try accessMetaAtCurrentIndex()
        let value = try decoder.unwrap(subMeta, toType: type, for: currentCodingKey)

        // now we decoded a value with success,
        // therefor we can increment currentIndex
        self.currentIndex += 1

        return value

    }

    // MARK: - nested containers

    open func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {

        let subMeta = try accessMetaAtCurrentIndex()
        let path = codingPath + [currentCodingKey]
        
        let newContainer = try decoder.container(keyedBy: keyType, for: subMeta, at: path)
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1

        return newContainer

    }

    open func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {

        let subMeta = try accessMetaAtCurrentIndex()
        let path = codingPath + [currentCodingKey]
        
        let newContainer = try decoder.unkeyedContainer(for: subMeta, at: path)
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        
        return newContainer

    }

    // MARK: - super encoder

    open func superDecoder() throws -> Decoder {

        let subMeta = try accessMetaAtCurrentIndex()
        let path = codingPath + [currentCodingKey]
        
        let superDecoder = try decoder.decoder(for: subMeta, at: path)
        
        self.currentIndex += 1
        return superDecoder

    }

    // MARK: Utilities
    
    private var currentCodingKey: CodingKey {
        
        return IndexCodingKey(intValue: self.currentIndex)!
        
    }
    
    private func accessMetaAtCurrentIndex() throws -> Meta {
        
        guard let subMeta = meta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "UnkeyedContainer is at end.")
            throw DecodingError.valueNotFound(Any?.self, context)
            
        }
        
        return subMeta
        
    }
    
}
