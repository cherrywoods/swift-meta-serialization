//
//  Serialization+Default Implementations.swift
//  meta-serialization
//
//  Created by cherrywoods on 24.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

public extension IntermediateEncoder {
    
    func encode<E: Encodable>(value: E) throws -> Raw {
        
        let encoder = self.provideNewEncoder()
        
        try value.encode(to: encoder)
        
        return try encoder.representationOfEncodedValue() as Raw
        
    }
    
}

public extension IntermediateDecoder {
    
    func decode<D: Decodable>(toType type: D.Type, from raw: Raw) throws -> D {
        
        let decoder = self.provideNewDecoder(raw: raw)
        
        return try type.init(from: decoder)
        
    }
    
}
