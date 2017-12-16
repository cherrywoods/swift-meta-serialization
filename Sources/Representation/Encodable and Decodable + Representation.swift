//
//  Encodable and Decodable + Representation.swift
//  MetaSerialization
//
//  Created by cherrywoods on 16.12.17.
//

import Foundation

extension Encodable {
    
    func encode(to representation: Representation) throws {
        
        try self.encode(to: representation.encoder)
        
    }
    
}

extension Decodable {
    
    init(from representation: Representation) throws {
        
        try self.init(from: representation.decoder)
        
    }
    
}
