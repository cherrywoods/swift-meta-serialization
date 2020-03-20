//
//  DirectlyCodable.swift
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
 implement this protocol if a type is supported directly by the Translator and you won't have to write any code for coding.
 For implementation details, see DirectlyDecodable and DirectlyEncodable
 - Throws: The same errors as Decoder.singleValueContainer() and SingleValueContainer.decode(<implementing type>)
 */
public typealias DirectlyCodable = DirectlyDecodable & DirectlyEncodable

/**
 Implement this protocol if a type is supported directly by the Translator.
 
 MetaSerialization will throw an error, if a unwrapper does not support the implementing type directly.
 */
public protocol DirectlyDecodable: Decodable {}

public extension DirectlyDecodable {
    
    init(from decoder: Decoder) throws {
        assertionFailure("Should not call init(from:) initalizer of DirectlyDecodable type. Rather call decode on a container. Request a single value container, if you want to decode just one value.")
        // this implementation seems to match the implementation of String, Int, etc.
        // this implementation can cause endless loops and is therefor guarded by an assertion failure
        self = try decoder.singleValueContainer().decode(Self.self)
    }
    
}

/**
 Implement this protocol if a type is supported directly by the Translator.
 
 MetaSerialization will throw an error, if a translator does not support your type directly.
 */
public protocol DirectlyEncodable: Encodable {}

public extension DirectlyEncodable {
    
    func encode(to encoder: Encoder) throws {
        assertionFailure("Should not call encode(to:) of DirectlyEncodable type. Rather call encode on a container. Request a single value container, if you want to encode just one value.")
        // this implementation seems to match the implementation of String, Int, etc.
        // this implementation can cause endless loops and is therefor guarded by an assertion failure
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }
    
}
