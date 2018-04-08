//
//  TestUtilities.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense.
//  See https://www.unlicense.org
//

import XCTest
import Nimble
@testable import MetaSerialization

struct TestUtilities {
    
    private init() {}
    
    static func roundTrip<T: Codable&Equatable, S: Serialization>(_ value: T,
                                                                  using serialization: S,
                                                                  expected: S.Raw? = nil) where S.Raw: Equatable {
        
        let encoded = encode(value, using: serialization, expected: expected)
        guard encoded != nil else { return }
        _ = decode(from: encoded!, to: type(of: value), using: serialization, expected: value)
        
    }
    
    static func encode<T: Encodable, S: Serialization>(_ value: T,
                                                       using serialization: S,
                                                       expected: S.Raw? = nil) -> S.Raw? where S.Raw: Equatable {
        
        do {
            
            let result = try serialization.encode(value)
            
            if expected != nil {
                
                expect(expected!).to(equal(result), description: "Encoded value should match the expected result.")
            }
            
            return result
            
        } catch {
            fail("Failed to encode value: \(value) with error: \(error)")
            return nil
        }
        
    }
    
    static func decode<T: Decodable&Equatable, S: Serialization>(from raw: S.Raw,
                                                                 to type: T.Type,
                                                                 using serialization: S,
                                                                 expected: T? = nil) -> T? {
        
        do {
            
            let decoded = try serialization.decode(toType: type, from: raw)
            
            if expected != nil {
                expect(expected!).to( equal(decoded), description: "Decoded value should match the expected result." )
            }
            
            return decoded
            
        } catch {
            fail("Failed to decode type: \(T.self) with error: \(error)")
            return nil
        }
        
    }
    
    // MARK: failures
    
    static func roundTripTypeCoercionFails<T: Codable, U: Codable, S: Serialization>(_ value: T, as type: U.Type, using serialization: S) {
        
        do {
            
            let result = try serialization.encode(value)
            _ = try serialization.decode(toType: type, from: result)
            fail("Coercion from \(T.self) value: \(value) to type \(U.self) was expected to fail but succeeded.")
            
        } catch DecodingError.typeMismatch(_, _) {
            
            // this is the error we want
            
        } catch {
            
            fail("Unexpected error was thrown: \(error)")
            
        }
        
    }
    
    static func encodeFails<T: Encodable, S: Serialization>(_ value: T, using serialization: S) {
        
        do {
            
            _ = try serialization.encode(value)
            fail("Encoding value: \(value) was expected to fail.")
            
        } catch {}
        
    }

    static func encodeFailsWithInvalidValue<T: Codable, S: Serialization>(_ value: T, using serialization: S) {
        
        do {
            
            _ = try serialization.encode(value)
            fail("Encoding value: \(value) was expected to fail.")
            
        } catch EncodingError.invalidValue(_, _) {
            
            // this is the error we want
            
        } catch {
            
            fail("Unexpected error was thrown: \(error)")
            
        }
        
    }
    
    static func decodeFails<T: Decodable, S: Serialization>(_ type: T.Type, from raw: S.Raw, using serialization: S) {
        
        do {
            
            _ = try serialization.decode(toType: type, from: raw)
            fail("Decoding type: \(type) from \(raw) was expected to fail.")
            
        } catch {}
        
    }

    static func decodeFailsWithTypeMissmatch<T: Codable, S: Serialization>(_ type: T.Type, from raw: S.Raw, using serialization: S) {
        
        do {
            
            _ = try serialization.decode(toType: type, from: raw)
            fail("Decoding type: \(type) from \(raw) was expected to fail.")
            
        } catch DecodingError.typeMismatch(_, _) {
            
            // this is the error we want
            
        } catch {
            
            fail("Unexpected error was thrown: \(error)")
            
        }
        
    }
    
    // MARK: - Helper Global Functions
    static func expectEqualPaths(_ lhs: [CodingKey], _ rhs: [CodingKey], _ prefix: String) {
        
        if lhs.count != rhs.count {
            fail("CodingKeys not equal: \(lhs) != \(rhs)")
            return
        }
        
        for (key1, key2) in zip(lhs, rhs) {
            switch (key1.intValue, key2.intValue) {
            case (.none, .none): break
            case (.some(let i1), .some(let i2)):
                guard i1 == i2 else {
                    fail("CodingKeys not equal: \(lhs) != \(rhs)")
                    return
                }
                
                break
            default:
                fail("CodingKeys not equal: \(lhs) != \(rhs)")
                return
            }
            
            expect(key1.stringValue).to(equal(key2.stringValue))
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
        
        func wrap<T>(_ value: T, for encoder: MetaEncoder) -> Meta? {
            return nil
        }
        
        func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? {
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
