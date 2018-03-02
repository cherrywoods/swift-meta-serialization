//
//  MultipleContainerRequests.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See https://www.unlicense.org
// 

import XCTest
@testable import MetaSerialization

// tests MetaEncoder+containerMethods line 34

class MultipleContainerRequestsTests: XCTestCase {
    
    func testMultipleContainerRequests() {
        
        let encodingClosure = { (encoder: Encoder) in
            
            let _ = encoder.unkeyedContainer()
            let _ = encoder.unkeyedContainer()
            
        }
        
        let encodable = TestUtilities.TestCodable(encode: encodingClosure)
        let serialization = TestUtilities.containerSerialization()
        let emptyArray = Container.array([])
        
        _ = TestUtilities.testEncoding(of: encodable, using: serialization, expected: emptyArray)
        
    }
    
}

