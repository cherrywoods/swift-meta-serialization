//
//  PerformanceTests.swift
//  MetaSerializationTests-iOS
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
@testable import MetaSerialization

class PerformanceTests: XCTestCase {

    var array: [Int]!
    var encodedArray: Example2Meta!
    
    var tree: Tree<Int>!
    var encodedTree: Example2Meta!
    
    override func setUp() {
        
        array = [Int](repeating: 0, count: 1000)
        encodedArray = .array( [Example2Meta](repeating: .string("0"), count: 1000) )
        
        tree = Tree<Int>(dummy: 0, depth: 1000, width: 1)
        // create the encoded tree
        var last = Example2Meta.array( [.string("value"), .string("0"), .string("children"), .array([])] )
        for _ in (0..<1000) {
            last = Example2Meta.array( [.string("value"), .string("0"), .string("children"), .array( [ last ])] )
        }
        encodedTree = .array([.string("root"), last])
        
    }
    
    // MARK: - Array
    // MARK: LinearCodingStack
    
    func testPerformanceOfEncodingSingleValuesLinearCodingStack() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.linearCodingStackSerialization
        
        self.measure {
            
            _ = try! serialization.encode(array)
            
        }
        
    }

    func testPerformanceOfDecodingSingleValuesLinearCodingStack() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.linearCodingStackSerialization
        
        self.measure {
            
            _ = try! serialization.decode(toType: [Int].self, from: encodedArray)
            
        }
        
    }

    // MARK: CodingDictionary
    
    func testPerformanceOfEncodingSingleValuesCodingDictionary() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.codingDictionarySerialization
        
        self.measure {
            
            _ = try! serialization.encode(array)
            
        }
        
    }
    
    func testPerformanceOfDecodingSingleValuesCodingDictionary() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.codingDictionarySerialization
        
        self.measure {
            
            _ = try! serialization.decode(toType: [Int].self, from: encodedArray)
            
        }
        
    }

    // MARK: - Tree
    // MARK: LinearCodingStack
    
    func testPerformanceOfEncodingDeeplyNestedLinearCodingStack() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.linearCodingStackSerialization
        
        self.measure {
            
            _ = try! serialization.encode(tree)
            
        }
        
    }
    
    func testPerformanceOfDecodingDeeplyNestedLinearCodingStack() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.linearCodingStackSerialization
        
        self.measure {
            
            _ = try! serialization.decode(toType: Tree<Int>.self, from: encodedTree)
            
        }
        
    }
    
    // MARK: CodingDictionary
    
    // Inefficient => remove
    
    func testPerformanceOfEncodingDeeplyNestedCodingDictionary() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.codingDictionarySerialization
        
        self.measure {
            
            _ = try! serialization.encode(tree)
            
        }
        
    }
    
    func testPerformanceOfDecodingDeeplyNestedCodingDictionary() {
        
        // this performace test will encode a large array of single values
        // by doing this it should test mainly the performance of the encode and wrap methods.
        
        let serialization = Example2.codingDictionarySerialization
        
        self.measure {
            
            _ = try! serialization.decode(toType: Tree<Int>.self, from: encodedTree)
            
        }
        
    }
}
