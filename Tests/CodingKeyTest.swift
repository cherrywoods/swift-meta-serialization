//
//  CodingKeyTest.swift
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

class CodingKeySpec: QuickSpec {
    
    override func spec() {
        
        describe("StandardCodingKey") {
            
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
            
            describe("equal values are equal") {
                
                // only keys with equal string and int values should be == 
                
                let k1 = StandardCodingKey(stringValue: "key", intValue: 1)
                let k2 = StandardCodingKey(stringValue: "key")
                let k3 = StandardCodingKey(intValue: 1)
                
                expect(k1).to(equal(k1))
                expect(k2).to(equal(k2))
                expect(k3).to(equal(k3))
                
                expect(k1).toNot(equal(k2))
                expect(k1).toNot(equal(k3))
                
                expect(k2).toNot(equal(k1))
                expect(k2).toNot(equal(k3))
                
                expect(k3).toNot(equal(k1))
                expect(k3).toNot(equal(k2))
                
            }
            
        }
        
        describe("IndexCodingKey") {
            
            it("initalization with int values forwards int values and sets string values") {
                
                let key = IndexCodingKey(intValue: 5)
                expect(key?.stringValue).to(equal("5"))
                expect(key?.intValue).to(equal(5))
                
            }
            
            it("initalizes with convertible string value") {
                
                let key = IndexCodingKey(stringValue: "2")
                expect(key?.intValue).to(equal(2))
                
            }
            
            it("fails to initalizs which unconvertible string value") {
                
                let key = IndexCodingKey(stringValue: "text")
                expect(key).to(beNil())
                
            }
            
            it("does fails on initalization with negative int values") {
                
                let k1 = IndexCodingKey(intValue: -1)
                let k2 = IndexCodingKey(stringValue: "-1")
                
                expect(k1).to(beNil())
                expect(k2).to(beNil())
                
            }
            
        }
        
    }
    
}
