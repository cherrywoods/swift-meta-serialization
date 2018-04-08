//
//  AdditionalCodables.swift
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

import XCTest

struct MultipleContainerRequestsType: Encodable {
    
    func encode(to encoder: Encoder) throws {
        _ = encoder.unkeyedContainer()
        _ = encoder.unkeyedContainer()
    }
    
}

struct ThrowingOnEncode: Encodable {
    
    func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "throwing on encode"))
    }
    
}

extension EitherDecodable: Equatable where T: Equatable, U: Equatable {
    
    static func == (lhs: EitherDecodable<T, U>, rhs: EitherDecodable<T, U>) -> Bool {
        
        switch (lhs, rhs) {
        case (.t(let lhValue), .t(let rhValue)):
            return lhValue == rhValue
        case (.u(let lhValue), .u(let rhValue)):
            return lhValue == rhValue
        default:
            return false
        }
        
    }
    
}
