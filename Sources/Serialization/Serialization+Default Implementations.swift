//
//  Serialization+Default Implementations.swift
//  meta-serialization
//
//  Created by cherrywoods on 24.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

public extension IntermediateEncoder {
    
    /// encodes the given value into a raw representation
    func encode<E: Encodable>(_ value: E) throws -> Raw {
        
        let encoder = self.provideNewEncoder()
        
        return try encoder.encode(value) as Raw
        
    }
    
}

public extension IntermediateDecoder {
    
    /// decodes a value of the given type from a raw representation
    func decode<D: Decodable>(toType type: D.Type, from raw: Raw) throws -> D {
        
        let decoder = try self.provideNewDecoder(raw: raw)
        
        // force unwrap,
        // because decoder was freshly initalized
        return (try decoder.decode(type: type))!
        
    }
    
}
