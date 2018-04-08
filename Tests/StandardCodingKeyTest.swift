//
//  StandardCodingKeyTest.swift
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

import Quick
import Nimble
@testable import MetaSerialization

class StandardCodingKeySpec: QuickSpec {
    
    override func spec() {
        
        describe("literal initalization") {
            
            it("is initalizable with string and int value") {
                
                let key: StandardCodingKey = "abcdef,70"
                expect(key.stringValue).to(equal("abcdef"))
                expect(key.intValue).to(equal(70))
                
            }
            
            it("is initalizable with string literal") {
                
                let key: StandardCodingKey = "abcdef"
                expect(key.stringValue).to(equal("abcdef"))
                expect(key.intValue).to(beNil())
                
            }
            
            it("is initalizable with int literal") {
                
                let key: StandardCodingKey = ",42"
                expect(key.stringValue).to(equal("42"))
                expect(key.intValue).to(equal(42))
                
            }
            
            it("works with multiple kommas") {
                
                let key: StandardCodingKey = "first, second, third,1000000"
                expect(key.stringValue).to(equal("first, second, third"))
                expect(key.intValue).to(equal(1000000))
                
            }
            
        }
        
        describe("string and int value initalizer") {
            
            it("forwards both values") {
                
                let key = StandardCodingKey(stringValue: "test", intValue: 32)
                expect(key.stringValue).to(equal("test"))
                expect(key.intValue).to(equal(32))
                
            }
            
        }
        
        describe("string value initalizer") {
            
            it("sets int value to nil") {
                
                let key = StandardCodingKey(stringValue: "7")
                expect(key?.stringValue).to(equal("7"))
                expect(key?.intValue).to(beNil())
                
            }
            
        }
        
        describe("int value initalizer") {
            
            it("sets string value to int value") {
                
                let key = StandardCodingKey(intValue: 0)
                expect(key?.stringValue).to(equal("0"))
                expect(key?.intValue).to(equal(0))
                
            }
            
        }
        
    }
    
}
