//
//  Representation.swift
//  meta-serialization
//
//  Created by cherrywoods on 23.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 A protocol for any kind of encoded data, for example Data, or [String:Any].
 
 To use this protocol extend your raw data type to conform to this protocol.
 All you have to do then is implementing coder with a TranslatingCoder, that you will initalize with your implementation of Translator.
 
 After extending your raw type, you can use the init(from: Decoder) and encode(to: Encoder) methods of your Decodable and Encodable swift types directly.
 
 It is usefull to write a subprotocol of Representation before you extend your raw data type. For example, if you want to write another library for pasing JSON, first write a protocol JSON: Representation, for which you provide the default implementation in an extension and then extends your raw type, e.g. Data by JSON.
 When you encode or decode to or from the raw type you should give the reader and swift a hint what format to use, by adding `as JSON` to the raw types object. This will save you time if you decide to add another serialization framwork to your application that has the same raw representation type and will give some hints about what you are doing right inside your code.
 */
public typealias Representation = EncodingRepresentation & DecodingRepresentation

/**
 A protocol for encoded data, that will only be written.
 
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
    
}

/**
 A protocol for encoded data, that will only be read.
 
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
    
}
