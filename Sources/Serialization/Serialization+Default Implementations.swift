//
//  Serialization+Default Implementations.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
        
        let decoder = self.provideNewDecoder()
        
        // force unwrap,
        // because decoder was freshly initalized
        return try decoder.decode(type: type, from: raw)
        
    }
    
}
