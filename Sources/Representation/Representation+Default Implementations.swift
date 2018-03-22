//
//  Representation+Default Implementations.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

public extension EncodingRepresentation {
    
    init<E: Encodable>(encoding value: E) throws {
        
        let meta = try Self.provideNewEncoder().encode(value)
        try self.init(meta: meta)
        
    }
    
}

public extension DecodingRepresentation {
    
    func decode<D: Decodable>(type: D.Type) throws -> D {
        
        let meta = try self.convert()
        return try provideNewDecoder().decode(type: type, from: meta)
        
    }
    
}
