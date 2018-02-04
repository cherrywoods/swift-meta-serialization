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
 */
public extension DirectlyDecodable {
    
    public init(from decoder: Decoder) throws {
        // The old code caused a crash afterwards
        // with a worse description
        preconditionFailure("A type conforming to DirectlyDecodable was not accepted by the Translator implementation")
    }
    
}

/**
 implement this protocol if a type is supported directly by the Translator and you won't have to write any code for encoding.
 */
public protocol DirectlyEncodable: Encodable {  }

public extension DirectlyEncodable {
    
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("A type conforming to DirectlyEncodable was not accepted by the Translator implementation")
    }
    
}
