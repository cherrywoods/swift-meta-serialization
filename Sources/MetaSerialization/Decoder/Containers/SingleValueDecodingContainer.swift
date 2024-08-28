//
//  SingleValueDecodingContainer.swift
//  meta-serialization
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

/**
 Manages all kinds of metas, that represent some kind of single value
 */
open class MetaSingleValueDecodingContainer: SingleValueDecodingContainer {
    
    /**
     This MetaSingleValueDecodingContainer's meta.
     */
    public let meta: Meta
    
    /**
     The decoder that created this container.
     
     Decoding is delegated to it.
     */
    public let decoder: MetaDecoder
    
    public let codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(for meta: Meta, at codingPath: [CodingKey], decoder: MetaDecoder) {
        
        self.meta = meta
        self.codingPath = codingPath
        self.decoder = decoder
        
    }
    
    // MARK: decoding
    
    open func decodeNil() -> Bool {
        
        return decoder.representsNil(meta: meta)
        
    }
    
    open func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        // decode the meta stored at decoders codingPath
        return try decoder.unwrap(toType: type)
        
    }
    
}
