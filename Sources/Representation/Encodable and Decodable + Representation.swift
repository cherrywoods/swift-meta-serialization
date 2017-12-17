//
//  Encodable and Decodable + Representation.swift
//  MetaSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation

extension Encodable {
    
    mutating func encode(to representation: inout EncodingRepresentation) throws {
        
        try representation.encode(self as Self)
        
    }
    
}

extension Decodable {
    
    init(from representation: DecodingRepresentation) throws {
        
        self = try representation.decode(type: Self.self)
        
    }
    
}
