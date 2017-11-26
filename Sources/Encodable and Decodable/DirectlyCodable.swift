//
//  DirectlyCodable.swift
//  meta-serialization
//
//  Created by cherrywoods on 25.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 implement this protocol if a type is supported directly by the Translator and you won't have to write any code for coding.
 For implementation details, see DirectlyDecodable and DirectlyEncodable
 - Throws: The same errors as Decoder.singleValueContainer() and SingleValueContainer.decode(<implementing type>)
 */
public typealias DirectlyCodable = DirectlyDecodable & DirectlyEncodable

public protocol DirectlyDecodable: Decodable {  }

/**
 implement this protocol if a type is supported directly by the Translator and you won't have to write any code for decoding.

 - Implementation: requests a SingleValueContainer from the decoder in init(from:) and decodes a value of the implementing type. Any Error thrown by these two method calls is rethrown. If no error occured, self is set to the decoded type.
 - Throws: The same errors as Decoder.singleValueContainer() and SingleValueDecodingContainer.decode(<implementing type>)
 */
public extension DirectlyDecodable {
    
    public init(from decoder: Decoder) throws {
        // requests a single value container and directly decodes a value of the adopting types type
        let singleValueContainer = try decoder.singleValueContainer()
        self = try singleValueContainer.decode(Self.self)
    }
    
}

/**
 implement this protocol if a type is supported directly by the Translator and you won't have to write any code for encoding.
 
 - Implementation: requests a SingleValueContainer from the encoder in decode(to:) and encodes a value of the implementing type. Any Error thrown by encode() is rethrown.
 - Throws: The same errors SingleValueEncodingContainer.encode(<implementing type>)
 */
public protocol DirectlyEncodable: Encodable {  }

public extension DirectlyEncodable {
    
    public func encode(to encoder: Encoder) throws {
        // requests a single value container and directly encodes self
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(self)
    }
    
}
