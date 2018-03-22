//
//  TestUtilities.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense.
//  See https://www.unlicense.org
//

import XCTest
@testable import MetaSerialization

struct TestUtilities {
    
    private init() {}
    
    // MARK: - container serialization
    
    static func containerSerialization() -> SimpleSerialization<Container> {
        
        let translator = PrimitivesEnumTranslator(primitives: [ .nil, .bool, .string, .int, .double ],
                                                         encode: encodeToContainer,
                                                         decode: decodeFromContainer)
        
        return SimpleSerialization<Container>(translator, unwrapper: translator,
                                              encodeFromMeta: translator.encode,
                                              decodeToMeta: translator.decode)
        
    }
    
    static let serialization = containerSerialization()
    
    static func testContaienrRoundTrip<T: Codable&Equatable>(of value: T,
                                                             using serialization: SimpleSerialization<Container> = serialization,
                                                             expected: Container? = nil) {
        
        testRoundTrip(of: value, using: serialization, expected: expected)
        
    }
    
    static func testContainerEncoding<T: Encodable>(of value: T,
                                                    using serialization: SimpleSerialization<Container> = serialization,
                                                    expected: Container? = nil) -> Container? {
        
        return testEncoding(of: value, using: serialization, expected: expected)
        
    }
    
    static func testContainerDecoding<T: Decodable&Equatable>(from raw: Container,
                                                              to type: T.Type,
                                                              using serialization: SimpleSerialization<Container> = serialization,
                                                              expected: T? = nil) -> T? {
        
        return testDecoding(from: raw, to: type, using: serialization)
        
    }
    
    // MARK: - round trip
    
    static func testRoundTrip<T: Codable&Equatable, Raw: Equatable>(of value: T,
                                      using serialization: SimpleSerialization<Raw>,
                                      expected: Raw? = nil) {
        
        let encoded = testEncoding(of: value, using: serialization, expected: expected)
        
        if encoded != nil {
            
            let decoded = testDecoding(from: encoded!, to: type(of: value), using: serialization)
            
            if decoded != nil {
                
                XCTAssert(decoded! == value, "Value \(value) did not round-trip to the same value. Instead: \(decoded!)")
                
            }
            
        }
        
    }
    
    static func testEncoding<T: Encodable, Raw: Equatable>(of value: T,
                                                           using serialization: SimpleSerialization<Raw>,
                                                           expected: Raw? = nil) -> Raw? {
        
        var payload: Raw? = nil
        do {
            
            payload = try serialization.encode(value)
            
        } catch {
            XCTFail("Failed to encode \(T.self): \(error)")
        }
        
        if expected != nil {
            XCTAssert(expected! == payload!, "Produced not identical to expected.")
        }
        
        return payload
        
    }
    
    static func testDecoding<T: Decodable&Equatable, Raw>(from raw: Raw,
                                                                   to type: T.Type,
                                                                   using serialization: SimpleSerialization<Raw>,
                                                                   expected: T? = nil) -> T? {
        
        do {
            
            let decoded = try serialization.decode(toType: type, from: raw)
            
            if expected != nil {
                XCTAssert(decoded == expected!, "Produced not identical to expected.")
            }
            
            return decoded
            
        } catch {
            
            XCTFail("Failed to decode \(T.self): \(error)")
            return nil
            
        }
        
    }
    
    // MARK: - TestCodable
    
    struct TestCodable: Encodable {
        
        let encode: (Encoder) throws -> Void
        
        init(encode: @escaping (Encoder) throws -> Void) {
            self.encode = encode
        }
        
        func encode(to encoder: Encoder) throws {
            
            try encode(encoder)
            
        }
        
    }
    
    // MARK: - ErrornousTranslator
    
    /// This encoder will produce errors at some point (it is possible to encode empty classes and structs with it)
    class ErrornousTranslator: MetaSupplier, Unwrapper {
        
        func wrap<T>(for value: T, at path: [CodingKey]) -> Meta? {
            return nil
        }
        
        func unwrap<T>(meta: Meta, toType type: T.Type, at path: [CodingKey]) throws -> T? {
            return nil
        }
        
        func encode<Raw>(_ meta: Meta) throws -> Raw {
            return meta as! Raw
        }
        
        func decode<Raw>(_ raw: Raw) throws -> Meta {
            return raw as! Meta
        }
        
    }
    
}
