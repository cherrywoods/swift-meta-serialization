//
//  Serialization.swift
//  MetaSerialization
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
 This protocol provides a blueprint for a serialization class.
 
 A serialization class is an intermediate, delegating the tasks of encoding and decoding to an Encoder or Decoder, but does so while the user creates a new instance of it and uses this classes methods instead of them of Encodable and Decodable (as one would if you used Representation)
 */
public typealias Serialization = IntermediateEncoder & IntermediateDecoder

/**
 This protocol provides a blueprint for an intermediate encoder, that does simply delegate the task of encoding to a `Encoder`.
 */
public protocol IntermediateEncoder {
    
    /// the raw type you encode to and decode from, for example Data
    associatedtype Raw
    
    /// encodes the given value into a raw representation
    func encode<E: Encodable>(_ value: E) throws -> Raw
    
    /// returns a new MetaEncoder
    func provideNewEncoder() -> MetaEncoder
    func convert(meta: Meta) throws -> Raw
    
}

/**
 This protocol provides a blueprint for an intermediate decoder, that does simply delegate the task of decoding to a Decoder.
 */
public protocol IntermediateDecoder {
    
    /// the raw type you encode to and decode from, for example Data
    associatedtype Raw
    
    /// decodes a value of the given type from a raw representation
    func decode<D: Decodable>(toType type: D.Type, from raw: Raw) throws -> D
    
    /// returns a new MetaDecoder
    func provideNewDecoder() -> MetaDecoder
    func convert(raw: Raw) throws -> Meta
    
}
