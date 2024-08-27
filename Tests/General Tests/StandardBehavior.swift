//
//  StandardBehavior.swift
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

// the test cases in this file are the same as the JSONEncoder tests in the file TestJSONEncoder from swift (see README).
// Those tests are licensed under the Apache License v2.0 with Runtime Library Exception (Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors)

import XCTest
import Quick
import Nimble
@testable import MetaSerialization

struct StandardBehavior<S: Serialization> where S.Raw: Equatable {
    
    let serialization: S
    let qs: QuickSpec.Type
    
    // keys for expected:
    // empty, empty unkeyed,
    // Switch.on, Switch.off, Timestamp, Counter, EnhancedBool.true, EnhancedBool.false, EnhancedBool.fileNotFound
    // wrapped(_one_of_the_above_),
    // Address, Person,
    // Numbers, Mapping,
    // Company,
    // Button,
    // Employee,
    // CoffeeDrinker,
    func test(expected: [String : S.Raw], allowTopLevelSingleValues allowTLSV: Bool, allowNestedContainers allowNC: Bool, allowNils: Bool) {
        
        qs.describe("emptys") {
            
            testSingle("empty struct", value: EmptyStruct(), expected: expected["empty"])
            testSingle("empty class", value: EmptyClass(), expected: expected["empty"])
            
        }
        
        qs.describe("top level singles") {
            
            failOrSucceed(succeed: allowTLSV, "Switch.on", value: Switch.on, expected: expected["Switch.on"])
            failOrSucceed(succeed: allowTLSV, "Switch.off", value: Switch.off, expected: expected["Switch.off"])
            failOrSucceed(succeed: allowTLSV, "Timestamp", value: Timestamp(3141592653), expected: expected["Timestamp"])
            failOrSucceed(succeed: allowTLSV, "Counter", value: Counter(), expected: expected["Counter"])
            
            failOrSucceed(succeed: allowTLSV, "EnhancedBool.true", value: EnhancedBool.true, expected: expected["EnhancedBool.true"])
            failOrSucceed(succeed: allowTLSV, "EnhancedBool.false", value: EnhancedBool.false, expected: expected["EnhancedBool.false"])
            failOrSucceed(succeed: allowTLSV && allowNils, "EnhancedBool.fileNotFound", value: EnhancedBool.fileNotFound, expected: expected["EnhancedBool.fileNotFound"])
            
        }
        
        qs.describe("wrapped top level singles") {
            
            testSingle("wrapped Switch.on", value: TopLevelWrapper(Switch.on), expected: expected["wrapped(Switch.on)"])
            testSingle("wrapped Switch.off", value: TopLevelWrapper(Switch.off), expected: expected["wrapped(Switch.off)"])
            testSingle("wrapped Timestamp", value: TopLevelWrapper(Timestamp(3141592653)), expected: expected["wrapped(Timestamp)"])
            testSingle("wrapped Counter", value: TopLevelWrapper(Counter()), expected: expected["wrapped(Counter)"])

            testSingle("wrapped EnhancedBool.true", value: TopLevelWrapper(EnhancedBool.true), expected: expected["wrapped(EnhancedBool.true)"])
            testSingle("wrapped EnhancedBool.false", value: TopLevelWrapper(EnhancedBool.false), expected: expected["wrapped(EnhancedBool.false)"])
            failOrSucceed(succeed: allowNils, "wrapped EnhancedBool.fileNotFound", value: TopLevelWrapper(EnhancedBool.fileNotFound), expected: expected["wrapped(EnhancedBool.fileNotFound)"])
            
        }
        
        qs.describe("top level structured types") {
            
            testSingle("Address", value: Address.testValue, expected: expected["Address"])
            testSingle("Person", value: Person.testValue, expected: expected["Person"])
            
        }
        
        qs.describe("structures type though single value container") {
            
            testSingle("Number", value: Numbers.testValue, expected: expected["Numbers"])
            failOrSucceed(succeed: allowNils, "Mapping", value: Mapping.testValue, expected: expected["Mapping"])
            
        }
        
        qs.describe("deep structured class") {
            
            failOrSucceed(succeed: allowNC, "company", value: Company.testValue, expected: expected["Company"])
            
        }
        
        qs.describe("deep nested class") {
            
            failOrSucceed(succeed: allowNC, "button", value: Button.testValue, expected: expected["Button"])
            
        }
        
        qs.describe("class sharing encoder with super") {
            
            testSingle("employee", value: Employee.testValue, expected: expected["Employee"])
            
        }
        
        qs.describe("class using super encoder") {
            
            failOrSucceed(succeed: allowNC, "coffee drinker", value: CoffeeDrinker.testValue, expected: expected["CoffeeDrinker"])
            
        }
        
        qs.describe("encoder features") {
            
            // these tests can't work if nested containers aren't allowed
            
            if allowNC {
                
                qs.it("does nested container coding paths right") {
                    _ = TestUtilities.encode(NestedContainersTestType(), using: self.serialization)
                }
                
                qs.it("does super encoder coding paths right") {
                    _ = TestUtilities.encode(NestedContainersTestType(testSuperEncoder: true), using: self.serialization)
                }
                
            }
            
        }
        
        qs.it("allows requesting equal containers multiple times") {
            
            _ = TestUtilities.encode(MultipleContainerRequestsType(), using: self.serialization, expected: expected["empty unkeyed"])
            
        }
        
        
    }
    
    func failOrSucceed<T: Codable&Equatable>(succeed allowed: Bool, _ description: String, value: T, expected: S.Raw?) {
        
        if allowed {
            
            testSingle(description, value: value, expected: expected)
            
        } else {
            
            // expect encoding failure
            qs.it("encoding " + description + " fails") {
                
                TestUtilities.encodeFails(value, using: self.serialization)
                
            }
            
        }
        
    }
    
    func testSingle<T: Codable&Equatable>(_ description: String, value: T, expected: S.Raw?) {
        
        qs.it("round trips " + description) {
            
            TestUtilities.roundTrip(value, using: self.serialization, expected: expected)
            
        }
        
    }
    
}
