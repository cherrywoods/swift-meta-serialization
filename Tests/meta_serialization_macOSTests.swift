//
//  meta_serialization_macOSTests.swift
//  meta_serialization_macOSTests
//
//  Created by cherrywoods on 27.10.17.
//

import XCTest
@testable import MetaSerialization

class meta_serialization_macOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMetaCoding() {
        
        // our object to encode and decode
        let merlinTheMapleTree = Tree(name: "Merlin", species: .maple, age: 201, height: 10, numberOfBranches: 7)
        
        let translator = UselessTranslator()
        let encoder = MetaEncoder(translator: translator)
        
        // var because compiler is stupid and does not understands that the this var WILL be set, if the second do clause is executed, because of error thrown and XCTFail call
        var kindOfRawMerlin: Meta?
        
        // encode
        do {
            try merlinTheMapleTree.encode(to: encoder)
            kindOfRawMerlin = try encoder.representationOfEncodedValue() as Meta
            
            
            // decode
            
            do {
                let decoder = try MetaDecoder(translator: translator, raw: kindOfRawMerlin!)
                let isThisStillMerlin = try Tree(from: decoder)
                
                //finals equality check
                XCTAssert(merlinTheMapleTree == isThisStillMerlin, "Initinal and decoded tree does not match: initinal: \(merlinTheMapleTree), decoded: \(isThisStillMerlin)")
                
                // if this succeds, encoding and decoding works in the very broad frame
                
            } catch {
                XCTFail("decoding merlin failed \(error)")
            }
            
        } catch {
            XCTFail("encoding merlin failed: \(error)")
        }
        
    }
    
}
