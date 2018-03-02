//
//  DirectlyCodable.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 implement this protocol if a type is supported directly by the Translator and you won't have to write any code for coding.
 For implementation details, see DirectlyDecodable and DirectlyEncodable
 - Throws: The same errors as Decoder.singleValueContainer() and SingleValueContainer.decode(<implementing type>)
 */
public typealias DirectlyCodable = DirectlyDecodable & DirectlyEncodable

/**
 Implement this protocol if a type is supported directly by the Translator.
 
 MetaSerialization will throw an error, if a translator does not support your type directly.
 Therefor init(from:) will never be called.
 */
public protocol DirectlyDecodable: Decodable {}

public extension DirectlyDecodable {
    
    public init(from decoder: Decoder) throws {
        preconditionFailure("Type was not accepted by the Translator implementation: \(Self.self)")
    }
    
}

/**
 Implement this protocol if a type is supported directly by the Translator.
 
 MetaSerialization will throw an error, if a translator does not support your type directly.
 Therefor encode(to:) will never be called.
 */
public protocol DirectlyEncodable: Encodable {}

public extension DirectlyEncodable {
    
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("Type was not accepted by the Translator implementation: \(type(of: self))")
    }
    
}
