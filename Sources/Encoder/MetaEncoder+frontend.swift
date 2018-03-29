//
//  MetaEncoder+frontend.swift
//  MetaSerialization
//
//  Copyright 2018 cherrywoods
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

import Foundation

public extension MetaEncoder {
    
    /**
     Encodes the given value to a meta tree.
     
     Use this method rather than directly calling encode(to:) of `Encodable`.
     encode(to:) will not detect types in the first place
     that are directly supported by the `MetaSupplier`.
     
     Example: If data is a Data instance and the `MetaSupplier` supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded the way Data encodes itself.
     
     - Throws: Aside from any errors that are thrown of metaSupplier.wrap and any `EncodingError` that has been thrown by another entity, this function will throw `MetaEncoder.Errors.encodingHasNotSucceeded` if the encoding could not succeed. In general, this error will never be thrown in code running unter the debug (and not the release) configuration. Instead the call will fail with an assertion failure. Such an error usually indicates an invalid encoder implementation.
     */
    public func encode<E: Encodable>(_ value: E) throws -> Meta {
        
        // encode over wrap function
        // this will keep E from encoding itself,
        // if it is supported by the meta supplier
        
        do {
            
            return try wrap(value)
            
        } catch let storageError as CodingStorageError {
            
            switch (storageError.reason) {
            case .alreadyStoringValueAtThisCodingPath: assertionFailure("Illegal encode: Double store at coding path: \(storageError.path)")
            case .pathNotFilled: assertionFailure("Misuse of CodingStorage: path not filled: \(storageError.path)")
            case .noMetaStoredAtThisCodingPath: assertionFailure("Misuse of CodingStorage: expected stored meta at path: \(storageError.path)")
            }
            
            throw Errors.encodingHasNotSucceeded
            
        } catch {
            
            throw error
            
        }
        
    }
    
    public enum Errors: Error {
        
        /// Thrown if the encoding process hasn't succeeded.
        case encodingHasNotSucceeded
        
    }
    
}
