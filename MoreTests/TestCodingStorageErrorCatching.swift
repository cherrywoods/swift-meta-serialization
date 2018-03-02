//
//  TestCodingStorageErrorCatching.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See https://www.unlicense.org
// 

// Tests MetaEncoder+frontend lines 40-47
// Tests MetaDecoder+frontend lines 36-43

import XCTest
import MetaSerialization

/// Tests that no CodingStorageErrors reach to the end user
class TestCodingStorageErrorCatching: XCTestCase {
    
    func testEncodingError() {
        
        let encoder = MetaEncoder(translator: ErrornousTranslator(), storage: ThrowingStorage())
        
        do {
            
            let _ = try encoder.encode(TestStruct()) as Meta
            
        } catch is CodingStorageError {
            
            XCTFail("CodingStorageError thrown to user")
            
        } catch MetaEncoder.Errors.encodingHasNotSucceeded {
            
            // this should be thrown
            
        } catch {
            
            // if another error is thrown, the test isn't designed well
            XCTFail("error: \(error)")
            
        }
        
    }
    
    func testDecodingError() {
        
        let decoder = MetaDecoder(translator: ErrornousTranslator(), storage: ThrowingStorage())
        
        do {
            
            let _ = try decoder.decode(type: TestStruct.self, from: NilMeta.nil)
            
        } catch is CodingStorageError {
            
            XCTFail("CodingStorageError thrown to user")
            
        } catch MetaDecoder.Errors.decodingHasNotSucceeded {
            
            // this should be thrown
            
        } catch {
            
            // if another error is thrown, the test isn't designed well
            XCTFail("error: \(error)")
            
        }
        
    }
    
}

fileprivate struct TestStruct: Codable {
    
    let string = "test"
    let int = 42
    
    init() {}
    
}

fileprivate class ErrornousTranslator: Translator {
    
    func wrappingMeta<T>(for value: T) -> Meta? {
        return nil
    }
    
    func unwrap<T>(meta: Meta, toType type: T.Type) throws -> T? {
        return nil
    }
    
    func encode<Raw>(_ meta: Meta) throws -> Raw {
        return meta as! Raw
    }
    
    func decode<Raw>(_ raw: Raw) throws -> Meta {
        return raw as! Meta
    }
    
}

fileprivate class ThrowingStorage: CodingStorage {
    
    subscript(codingPath: [CodingKey]) -> Meta {
        
        get {
            return NilMeta.nil
        }
        
        set(newValue) {}
        
    }
    
    func storesMeta(at codingPath: [CodingKey]) -> Bool {
        return false
    }
    
    func store(meta: Meta, at codingPath: [CodingKey]) throws {
        throw CodingStorageError.init(reason: .pathNotFilled, path: [])
    }
    
    func storePlaceholder(at codingPath: [CodingKey]) throws {
        throw CodingStorageError.init(reason: .pathNotFilled, path: [])
    }
    
    func remove(at codingPath: [CodingKey]) throws -> Meta? {
        throw CodingStorageError.init(reason: .pathNotFilled, path: [])
    }
    
    func lock(codingPath: [CodingKey]) throws {}
    
    func unlock(codingPath: [CodingKey]) {}
    
    func fork(at codingPath: [CodingKey]) -> CodingStorage {
        return self
    }
    
}
