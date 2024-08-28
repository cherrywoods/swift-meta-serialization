//
//  StateRestoringAfterThrow.swift
//  MetaSerialization
//  
//  Copyright 2018-2024 cherrywoods
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
import Quick
import Nimble
@testable import MetaSerialization

struct StateRestoringAfterThrow<S: Serialization> where S.Raw: Equatable {
    
    let serialization: S
    let qs: QuickSpec.Type
    
    // keys for expected:
    // encoded, toDecode,
    func test(information: [String : S.Raw]) {
        
        qs.it("restores state after throw during encode") {
            
            // encode something into container that throws on call of encode(to:)
            // encode something normal again: Should succeed in MetaSerialization
            _ = TestUtilities.encode(EncodingContainer(), using: self.serialization, expected: information["encoded"])
            
        }
        
        qs.it("restores state after throw during decode") {
            
            // This is an equivalent to the decoder state test of TestJSONEncoder
            // The issue resolved by this is: SR-6048
            
            // this comment is copied from TestJSONEncoder
            // The container stack here starts as [[1,2,3]]. Attempting to decode as [String] matches the outer layer (Array), and begins decoding the array.
            // Once Array decoding begins, 1 is pushed onto the container stack ([[1,2,3], 1]), and 1 is attempted to be decoded as String. This throws a .typeMismatch, but the container is not popped off the stack.
            // When attempting to decode [Int], the container stack is still ([[1,2,3], 1]), and 1 fails to decode as [Int].
            let decoded = TestUtilities.decode(from: information["toDecode"]!, to: EitherDecodable<[Int], [String]>.self, using: self.serialization)
        
            if let decoded = decoded {
                // the test already failed, if decoded is nil.
                guard case EitherDecodable<[Int], [String]>.u(_) = decoded else {
                    // if [String] was decoded, this test does not work.
                    fail("EitherDecodable test didn't result in the expected result.")
                    return
                }
                
            }
            
        }
        
    }
    
}

fileprivate struct EncodingContainer: Encodable {
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.unkeyedContainer()
        
        do {
            
            try container.encode( ThrowingOnEncode() )
            
        } catch {
            
            try container.encode("should work")
            
        }
        
    }
    
}
