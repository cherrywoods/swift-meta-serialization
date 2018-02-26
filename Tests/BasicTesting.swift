//
//  meta_serialization_macOSTests.swift
//  meta_serialization_macOSTests
//
//  Created by cherrywoods on 27.10.17.
//

import XCTest
@testable import MetaSerialization

/**
 In this test case a instance with nested other instances.
 */
class BasicTesting: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUsingPrimitvesEnumTranslator() {
        
        // our instances to encode and decode
        let merlin = Tree2(height: 10, width: 12.5, age: 201, kind: .maple)
        let claire = Tree2(height: 13, width: 11.6, age: 256, kind: .cherry)
        let forest = Forest(trees: [merlin, claire], location: "hill near the river")
        
        // this translator just converts to metas
        let translator = PrimitivesEnumTranslator(primitives: PrimitivesEnumTranslator.Primitive.all,
                                                  encode: { return $0 },
                                                  decode: { return $0 })
        
        let serialization = SimpleSerialization<Any?>(translator: translator)
        
        // encode
        do {
            
            let kindOfRawForest = try serialization.encode(forest) as Any?
            
            // decode
            
            do {
                let isThisStillOurForest = try serialization.decode(toType: Forest.self, from: kindOfRawForest)
                
                //final equality check
                XCTAssert(forest == isThisStillOurForest, "Initinal and decoded tree do not match: initinal: \(forest), decoded: \(isThisStillOurForest)")
                
            } catch {
                XCTFail("decoding merlin failed \(error)")
                return
            }
            
        } catch {
            XCTFail("encoding forest failed: \(error)")
            return
        }
        
    }
    
}
