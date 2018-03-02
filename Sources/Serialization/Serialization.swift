//
//  Serialization.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 This protocol provides a blueprint for a serialization class.
 
 A serialization class is an intermediate, delegating the tasks of encoding and decoding to an Encoder or Decoder, but does so while the user creates a new instance of it and uses this classes methods instead of them of Encodable and Decodable (as he would if you used Representation)
 */
public typealias Serialization = IntermediateEncoder & IntermediateDecoder

/**
 This protocol provides a blueprint for an intermediate encoder, that does simply delegate the task of encoding to a Encoder.
 */
public protocol IntermediateEncoder {
    
    /// the raw type you encode to and decode from, for example Data
    associatedtype Raw
    
    /// encodes the given value into a raw representation
    func encode<E: Encodable>(_ value: E) throws -> Raw
    
    /// returns a new MetaEncoder
    func provideNewEncoder() -> MetaEncoder
    
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
    
}
