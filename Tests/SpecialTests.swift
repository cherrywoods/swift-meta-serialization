//
//  SpecialTests.swift
//  MetaSerializationTests macOS
//
//  Created by cherrywoods on 06.02.18.
//
import XCTest
@testable import MetaSerialization

class SpecialTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*
     
     See https://github.com/apple/swift/commit/1e110b8f63836734113cdb28970ebcea8fd383c2
     
     Continue decoding after an 
     
     */
    
    func testContinueDecodingAfterError() {
        
        let triesToDecodeAsString = DecodesStrings( 12, 65, 42, 92 )
        
        let translator = PrimitivesEnumTranslator(primitives: PrimitivesEnumTranslator.Primitive.all,
                                                  encode: { return $0 },
                                                  decode: { return $0 })
        
        let serialization = SimpleSerialization<Any?>(translator: translator)
        
        // encode
        do {
            
            let encoded = try serialization.encode(triesToDecodeAsString) as Any?
            
            // decode
            
            do {
                
                let decoded = try serialization.decode(toType: DecodesStrings.self, from: encoded)
                
                XCTAssert(decoded.value == triesToDecodeAsString.value, "Initinal and decoded DecodesStrings do not match: initinal: \(triesToDecodeAsString), decoded: \(decoded)")
                
            } catch {
                XCTFail("decoding DecodesStrings failed \(error)")
                return
            }
            
        } catch {
            XCTFail("encoding DecodesStrings failed: \(error)")
            return
        }
        
    }
    
}
