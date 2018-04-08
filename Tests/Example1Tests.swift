//
//  Example1Tests.swift
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
import Quick
import Nimble
@testable import MetaSerialization

class Example1Spec: QuickSpec {
    
    override func spec() {
        
        let standardTests = StandardBehavior(serialization: Example1.serialization)
        standardTests.test(expected: [ "empty" : Example1Container.dictionary([:]),
                                       "empty unkeyed" : Example1Container.array([]),
                                       "person" : Example1Container.dictionary( [ "name": Example1Container.string( "Johnny Appleseed" ),
                                                                                  "email": Example1Container.string( "appleseed@apple.com" )] ),
                                       "EnhancedBool.true" : Example1Container.bool(true),
                                       "EnhancedBool.false" : Example1Container.bool(false),
                                       "EnhancedBool.fileNotFound" : Example1Container.nil,
                                       "wrapped(EnhancedBool.true)" : Example1Container.dictionary( ["value": Example1Container.bool(true)] ),
                                       "wrapped(EnhancedBool.false)" : Example1Container.dictionary( ["value": Example1Container.bool(false)] ),
                                       "wrapped(EnhancedBool.fileNotFound)" : Example1Container.dictionary( ["value": Example1Container.nil] ), ],
                           allowTopLevelSingleValues: true, allowNestedContainers: true, allowNils: true)
        
        let stateRestoreTests = StateRestoringAfterThrow(serialization: Example1.serialization)
        stateRestoreTests.test(information: [ "encoded" : Example1Container.array( [ .string("should work") ]),
                                              "toDecode" : Example1Container.array( [ .string("a"), .string("b"), .string("c") ] )] )
        
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
