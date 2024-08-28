//
//  Representation+Default Implementations.swift
//  MetaSerialization
//
//  Copyright 2018+2024 cherrywoods
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
