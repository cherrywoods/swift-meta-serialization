//
//  Representation+Default Implementations.swift
//  meta-serialization
//
//  Created by cherrywoods on 23.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

public extension EncodingRepresentation {
    
    init<E: Encodable>(encoding value: E) throws {
        
        self = try Self.provideNewEncoder().encode(value)
        
    }
    
}

public extension DecodingRepresentation {
    
    func decode<D: Decodable>(type: D.Type) throws -> D {
        
        return try provideNewDecoder().decode(type: type, from: self)
        
    }
    
}
