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

    static var allTests = [
        ("testPerformanceOfEncodingSingleValuesLinearCodingStack", testPerformanceOfEncodingSingleValuesLinearCodingStack),
        ("testPerformanceOfDecodingSingleValuesLinearCodingStack", testPerformanceOfDecodingSingleValuesLinearCodingStack),
        ("testPerformanceOfEncodingDeeplyNestedLinearCodingStack", testPerformanceOfEncodingDeeplyNestedLinearCodingStack),
        ("testPerformanceOfDecodingDeeplyNestedLinearCodingStack", testPerformanceOfDecodingDeeplyNestedLinearCodingStack),
    ]

    var array: [Int]!
    var encodedArray: Example1Container!
    
    var tree: Tree<Int>!
    var encodedTree: Example1Container!
    
    var serialization: SimpleSerialization<Example1Container>!
    
    override func setUp() {
        
        serialization = Example1.serialization
        
        array = [Int](repeating: 0, count: 1000)
        encodedArray = .array([Example1Container](repeating: .int(0), count: 1000))
        
        tree = Tree<Int>(dummy: 0, depth: 1000, width: 1)
        // create the encoded tree
        var last = Example1Container.dictionary(["value" : .int(0), "children" : .array([])])
        for _ in (0..<1000) {
            last = Example1Container.dictionary(["value" : .int(0), "children" : .array( [last] )])
        }
        encodedTree = .dictionary(["root" : last])
        
    }
    
    // MARK: - Array
    
    // this performace test will encode a large array of single values
    // by doing this it should test mainly the performance of the encode and wrap methods.
    
    func testPerformanceOfEncodingSingleValuesLinearCodingStack() {
        
        self.measure {
            
            _ = try! serialization.encode(array)
            
        }
        
    }

    func testPerformanceOfDecodingSingleValuesLinearCodingStack() {
        
        self.measure {
            
            _ = try! serialization.decode(toType: [Int].self, from: encodedArray)
            
        }
        
    }

    // MARK: - Tree
    
    // this performace test will encode a large array of single values
    // by doing this it should test mainly the performance of the encode and wrap methods.
    
    func testPerformanceOfEncodingDeeplyNestedLinearCodingStack() {
        
        self.measure {
            
            _ = try! serialization.encode(tree)
            
        }
        
    }
    
    func testPerformanceOfDecodingDeeplyNestedLinearCodingStack() {
        
        self.measure {
            
            _ = try! serialization.decode(toType: Tree<Int>.self, from: encodedTree)
            
        }
        
    }
    
}
