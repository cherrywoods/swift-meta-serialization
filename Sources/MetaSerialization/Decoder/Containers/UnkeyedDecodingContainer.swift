//
//  UnkeyedDecodingContainer.swift
//  meta-serialization
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

/**
 Manages a DecodingUnkeyedContainerMeta (for example, an Array).
 */
open class MetaUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    
    /**
     This MetaUnkeyedDecodingContainer's Meta.
     */
    public let meta: DecodingUnkeyedContainerMeta
    
    /**
     The Decoder that created this container.
     
     Decoding, creating new containers, and creating super decoders is delegated to it.
     */
    public let decoder: MetaDecoder
    
    public let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(for meta: DecodingUnkeyedContainerMeta, at codingPath: [CodingKey], decoder: MetaDecoder) {
        
        self.meta = meta
        self.codingPath = codingPath
        self.decoder = decoder
        
    }
    
    // MARK: - container methods

    open var count: Int? {
        return meta.numberOfMetasIfKnown
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

        let isNil = try decoder.representsNil(meta: accessMetaAtCurrentIndex())
        
        
        // as documentation says, we should only increment currentValue,
        // if the encoded value is nil
        if isNil { self.currentIndex += 1 }
        
        return isNil

    }

    open func decode<T: Decodable>(_ type: T.Type) throws -> T {

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
    
    /// An utility computed property that returns a coding key for the current index.
    public var currentCodingKey: CodingKey {
        
        return IndexCodingKey(intValue: self.currentIndex)!
        
    }
    
    /// An utility method that accesses the Meta stored at the current index and throws an error if not value is present.
    public func accessMetaAtCurrentIndex() throws -> Meta {
        
        guard let subMeta = meta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "UnkeyedContainer is at end.")
            throw DecodingError.valueNotFound(Any?.self, context)
            
        }
        
        return subMeta
        
    }
    
}
