//
//  Representation.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 A protocol for any kind of encoded information.
 
 To use this protocol extend your raw data type to conform to this protocol.
 Implement provideNewEncoder() and provideNewDecoder(). You may just return a new MetaEncoder/MetaDecoder there. Also implement convert() -> Meta and init(meta: Meta).
 
 After extending your raw type, use init(encoding: ) to encode and decode(type: ) to decode.
 
 It is usefull to write a subprotocol of Representation before you extend your raw data type.
 For example, if you want to write a library for parsing JSON,
 first write a marker protocol JSON: Representation, for which you provide the default implementation in an extension and then extends your raw type, e.g. Data by JSON.
 When you encode or decode to or from the raw type you should give the reader and swift a hint what format to use, by adding `as JSON` to the raw types object. This will save you time if you decide to add another serialization framwork to your application that has the same raw representation type and will give some hints about what you are doing right inside your code.
 */
public typealias Representation = EncodingRepresentation & DecodingRepresentation

/**
 A protocol for encoded data that will only be written.
 
 Please refer to the documentation of Representation for more information about usage.
 
 However, this protocol gives you also more control about the encoding process, because you will have to instantiate a new MetaEncoder, that you may pack with more information, than TranslatingCoder can handle.
 For example you may provide a userInfo dictionary or an initial codingPath.
 */
public protocol EncodingRepresentation {
    
    /**
     Inits encoding the given value
     */
    init<E: Encodable>(encoding value: E) throws
    
    /// returns a new MetaEncoder for self
    static func provideNewEncoder() -> MetaEncoder
    /// construct an instance of this type from a meta tree, created by an encoder returned from provideNewEncoder.
    init(meta: Meta) throws
    
}

/**
 A protocol for encoded data that will only be read.
 
 Please refer to the documentation of Representation for more information about usage.
 
 However, this protocol gives you also more control about the decoding process, because you will have to instantiate a new MetaDecoder, that you may pack with more information, than TranslatingCoder can handle.
 For example you may provide a userInfo dictionary or an initial codingPath.
 */
public protocol DecodingRepresentation {
    
    /**
     Decodes a value of the given type from this representation
     */
    func decode<D: Decodable>(type: D.Type) throws -> D
    
    /// returns a new MetaDecoder for self
    func provideNewDecoder() throws -> MetaDecoder
    /// construct a meta tree from this instance that can be used by a decoder returned from provideNewDecoder.
    func convert() throws -> Meta
    
}
