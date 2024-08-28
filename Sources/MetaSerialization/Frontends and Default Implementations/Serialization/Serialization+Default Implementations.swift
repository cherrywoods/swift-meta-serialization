//
//  Serialization+Default Implementations.swift
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
