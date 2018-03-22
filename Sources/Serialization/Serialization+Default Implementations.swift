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
        let meta = try encoder.encode(value)
        return try convert(meta: meta)
        
    }
    
}

public extension IntermediateDecoder {
    
    /// decodes a value of the given type from a raw representation
    func decode<D: Decodable>(toType type: D.Type, from raw: Raw) throws -> D {
        
        let decoder = self.provideNewDecoder()
        let meta = try convert(raw: raw)
        return try decoder.decode(type: type, from: meta)
        
    }
    
}
