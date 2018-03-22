//
//  TestEncoderStateRestoringAfterThrow.swift
//  MetaSerializationTests
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense.
//  See https://www.unlicense.org
//

import XCTest
@testable import MetaSerialization

class TestEncoderStateRestoringAfterThrow: XCTestCase {
    
    func testEncoderStateThrowOnEncode() {
        
        // encode something into container that throws on call of encode(to:)
        // encode something normal again: Should succeed in MetaSerialization
        
        struct EncodingContainer: Encodable {
            
            func encode(to encoder: Encoder) throws {
                
                var container = encoder.unkeyedContainer()
                
                do {
                    
                    try container.encode( ThrowingOnEncode() )
                    
                } catch {
                    
                    try container.encode("should work")
                    
                }
                
            }
            
        }
        
        let value = EncodingContainer()
        // the resulting Container should be an array with only one element
        let expected = Container.array( [ .string("should work") ] )
        let _ = TestUtilities.testEncoding(of: value, using: TestUtilities.containerSerialization(), expected: expected)
        
    }
    
}

struct ThrowingOnEncode: Encodable {
    
    func encode(to encoder: Encoder) throws {
        
        throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Bäh!"))
        
    }

}
