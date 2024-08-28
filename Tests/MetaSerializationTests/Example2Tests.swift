//
//  Example2Tests.swift
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

import Quick
import Nimble
@testable import MetaSerialization

class Example2Spec: QuickSpec {
    
    override class func spec() {
        
        let standardTests = StandardBehavior(serialization: Example2.serialization, qs: self)
        standardTests.test(expected: [ "empty" : Example2Meta.array([]),
                                       "empty unkeyed" : Example2Meta.array([]),
                                       "person" : Example2Meta.array([.string("name"), .string("Johnny Appleseed"),
                                                                      .string("email"), .string("appleseed@apple.com")]),
                                       "EnhancedBool.true" : Example2Meta.string("true"),
                                       "EnhancedBool.false" : Example2Meta.string("false"),
                                       "EnhancedBool.fileNotFound" : Example2Meta.string("nil"),
                                       "wrapped(EnhancedBool.true)" : Example2Meta.array( [.string("value"), .string("true")] ),
                                       "wrapped(EnhancedBool.false)" : Example2Meta.array( [.string("value"), .string("false")] ),
                                       "wrapped(EnhancedBool.fileNotFound)" : Example2Meta.array( [.string("value"), .string("nil")] ) ],
                           allowTopLevelSingleValues: false, allowNestedContainers: true, allowNils: true)
        
        let stateRestoreTests = StateRestoringAfterThrow(serialization: Example2.serialization, qs: self)
        stateRestoreTests.test(information: [ "encoded" : Example2Meta.array( [ .string("should work") ]),
                                              "toDecode" : Example2Meta.array( [ .string("a"), .string("b"), .string("c") ] )] )
        
        // test special type coercion failures:
        
        describe("errors") {
            
            it("does not allow wrong type coercion") {
                
                // one type coercion test should be enough, since this isn't actually a mechanism of MetaSerialization
                TestUtilities.roundTripTypeCoercionFails([false, true], as: [Int].self, using: Example1.serialization)
                
            }
            
            // Example1 does not support Int8 as primitive type
            
            it("does detect undecodable types") {
                
                TestUtilities.encodeFailsWithInvalidValue([0, 1] as [Int8], using: Example1.serialization)
                
            }
            
            it("does detect unencodable types") {
                
                TestUtilities.decodeFailsWithTypeMissmatch([Int8].self, from: Example1Container.array([.int(1), .int(2)]), using: Example1.serialization)
                
            }
            
        }
        
    }
    
}
