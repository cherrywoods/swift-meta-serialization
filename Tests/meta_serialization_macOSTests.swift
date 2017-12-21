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
    
    func test1() {
        
        // our object to encode and decode
        let merlinTheMapleTree = Tree(name: "Merlin", species: .maple, age: 201, height: 10, numberOfBranches: 7)
        
        let translator = UselessTranslator()
        let encoder = MetaEncoder(translator: translator)
        
        // encode
        do {
            try merlinTheMapleTree.encode(to: encoder)
            let kindOfRawMerlin = try encoder.representationOfEncodedValue() as Meta
            
            
            // decode
            
            do {
                let decoder = try MetaDecoder(translator: translator, raw: kindOfRawMerlin)
                let isThisStillMerlin = try Tree(from: decoder)
                
                //finals equality check
                XCTAssert(merlinTheMapleTree == isThisStillMerlin, "Initinal and decoded tree does not match: initinal: \(merlinTheMapleTree), decoded: \(isThisStillMerlin)")
                
                // if this succeds, encoding and decoding works in the very broad frame
                
            } catch {
                XCTFail("decoding merlin failed \(error)")
                return
            }
            
        } catch {
            XCTFail("encoding merlin failed: \(error)")
            return
        }
        
    }
    
    func test2() {
        
        // our object to encode and decode
        let merlin = Tree2(height: 10, width: 12.5, age: 201, kind: .maple)
        let claire = Tree2(height: 13, width: 11.6, age: 256, kind: .cherry)
        let forest = Forest(trees: [merlin, claire], location: "hill near the river")
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
                XCTAssert(forest == isThisStillOurForest, "Initinal and decoded tree does not match: initinal: \(forest), decoded: \(isThisStillOurForest)")
                
            } catch {
                XCTFail("decoding merlin failed \(error)")
                return
            }
            
        } catch {
            XCTFail("encoding merlin failed: \(error)")
            return
        }
        
    }
    
}
