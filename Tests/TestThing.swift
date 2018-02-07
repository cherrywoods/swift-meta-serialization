//
//  TestThing.swift
//  MetaSerializationTests macOS
//
//  Created by cherrywoods on 06.02.18.
//

import XCTest
@testable import MetaSerialization

class TestThing: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThing() {
        
        let thing = Thing(size: Thing.Dimensions(12.6, 65.1), attributes: Thing.Attributes("robust", "blue") )
        let namedThing = NamedThing(size: Thing.Dimensions(44.0, 1.5), attributes: Thing.Attributes("spartanic") , name: "Something undefined")
        
        let translator = PrimitivesEnumTranslator(primitives: PrimitivesEnumTranslator.Primitive.all,
                                                  encode: { return $0 },
                                                  decode: { return $0 })
        
        let serialization = SimpleSerialization<Any?>(translator: translator)
        
        // encode
        do {
            
            let encodedThing = try serialization.encode(thing) as Any?
            let encodedNamedThing = try serialization.encode(namedThing) as Any?
            
            // decode
            
            do {
                let decodedThing = try serialization.decode(toType: Thing.self, from: encodedThing)
                let decodedNamedThing = try serialization.decode(toType: NamedThing.self, from: encodedNamedThing)
                
                // just didn't implement Eqatable for Thing
                
                XCTAssert(thing.size.heigth == decodedThing.size.heigth, "Initinal and decoded thing do not match: initinal: \(thing), decoded: \(decodedThing)")
                XCTAssert(thing.size.width == decodedThing.size.width, "Initinal and decoded thing do not match: initinal: \(thing), decoded: \(decodedThing)")
                
                XCTAssert(namedThing.size.heigth == decodedNamedThing.size.heigth, "Initinal and decoded named thing do not match: initinal: \(namedThing), decoded: \(decodedThing)")
                XCTAssert(namedThing.size.width == decodedNamedThing.size.width, "Initinal and decoded named thing do not match: initinal: \(namedThing), decoded: \(decodedThing)")
                XCTAssert(namedThing.name == decodedNamedThing.name, "Initinal and decoded named thing do not match: initinal: \(namedThing), decoded: \(decodedThing)")
                
            } catch {
                XCTFail("decoding thing or namedThing failed \(error)")
                return
            }
            
        } catch {
            XCTFail("encoding thing or namedThing failed: \(error)")
            return
        }
        
    }
    
}
