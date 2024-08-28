//
//  TestCodingStorageErrorCatching.swift
//  TestAssertionGuarded
//  
//  Copyright 2018-2024 cherrywoods
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 

// Tests MetaEncoder+frontend lines 49-53
// Tests MetaDecoder+frontend lines 50-54

import XCTest
import MetaSerialization

/// Tests that no CodingStorageErrors reaches to the end user
class TestCodingStorageErrorCatching: XCTestCase {

    static var allTests = [
        ("testEncodingError", testEncodingError),
        ("testDecodingError", testDecodingError),
    ]
    
    func testEncodingError() throws {
        #if DEBUG
            throw XCTSkip("Run in release mode (swift test -c release) to run this test")
        #endif

        let encoder = MetaEncoder(metaSupplier: ErrornousTranslator(), storage: ThrowingStorage())
        
        do {
            
            let _ = try encoder.encode(TestStruct()) as Meta
            
        } catch is CodingStorageError {
            
            XCTFail("CodingStorageError thrown to user")
            
        } catch MetaEncoder.Errors.encodingHasNotSucceeded {
            
            // this should be thrown
            
        } catch {
            
            // if another error is thrown, this test isn't designed well
            XCTFail("error: \(error)")
            
        }
        
    }
    
    func testDecodingError() throws {
        #if DEBUG
            throw XCTSkip("Run in release mode (swift test -c release) to run this test")
        #endif

        let decoder = MetaDecoder(unwrapper: ErrornousTranslator(), storage: ThrowingStorage())
        
        do {
            
            let _ = try decoder.decode(type: TestStruct.self, from: NilMarker.instance)
            
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

fileprivate class ErrornousTranslator: MetaSupplier, Unwrapper {
    
    func wrap<T>(_ value: T, for encoder: MetaEncoder) throws -> Meta? where T : Encodable {
        return nil
    }
    
    func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? where T : Decodable {
        return nil
    }
    
}

fileprivate class ThrowingStorage: CodingStorage {
    
    subscript(codingPath: [CodingKey]) -> Meta {
        
        get {
            return NilMarker.instance
        }
        
        set(newValue) {}
        
    }
    
    func storesMeta(at codingPath: [CodingKey]) -> Bool {
        return false
    }
    
    func store(meta: Meta, at codingPath: [CodingKey]) throws {
        throw CodingStorageError(reason: .pathNotFilled, path: [])
    }
    
    func storePlaceholder(at codingPath: [CodingKey]) throws {
        throw CodingStorageError(reason: .pathNotFilled, path: [])
    }
    
    func remove(at codingPath: [CodingKey]) throws -> Meta? {
        throw CodingStorageError(reason: .pathNotFilled, path: [])
    }
    
    func fork(at codingPath: [CodingKey]) -> CodingStorage {
        return self
    }
    
}
