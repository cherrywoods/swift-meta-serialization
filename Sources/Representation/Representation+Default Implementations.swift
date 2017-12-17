//
//  Representation+Default Implementations.swift
//  meta-serialization
//
//  Created by cherrywoods on 23.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

public extension EncodingRepresentation {
    
    mutating func encode<E: Encodable>(_ value: E) throws {
        
        self = try provideNewEncoder().encode(value)
        
    }
    
}

public extension DecodingRepresentation {
    
    func decode<D: Decodable>(type: D.Type) throws -> D {
        
        return (try provideNewDecoder().decode(type: type))!
        
    }
    
}
