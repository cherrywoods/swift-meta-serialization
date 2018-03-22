//
//  MetaDecoder+frontend.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation

public extension MetaDecoder {
    
    /**
     Decodes a value of type D from the given meta tree.
     
     Use this method rather than directly calling Decodable.init(from:).
     init(from:) will not detect types that are directly supported by the unwrapper.
     
     - Throws: Aside from any errors that are thrown of unwrapper.unwrap and any `DecodingError` that has been thrown by another entity, this function will throw `MetaDecoder.Errors.decodingHasNotSucceeded` if the decoding could not succeed. In general, this error will never be thrown in code running unter the debug (and not the release) configuration. Instead the call will fail with an assertion failure.
     */
    public func decode<D: Decodable>(type: D.Type, from meta: Meta) throws -> D {
        
        do {
            
            // will store the decoded meta at the current path
            // if it isn't directly supported by the translator
            // this current path should be the root path of decoder,
            // but in principle it is also possible to call this somewhere else
            return try unwrap(meta, toType: type)
            
        } catch let storageError as CodingStorageError {
            
            switch (storageError.reason) {
            case .alreadyStoringValueAtThisCodingPath: assertionFailure("Illegal decode: Double store at coding path: \(storageError.path)")
            case .pathNotFilled: assertionFailure("Misuse of CodingStorage: path not filled: \(storageError.path)")
            case .noMetaStoredAtThisCodingPath: assertionFailure("Misuse of CodingStorage: expected stored meta at path: \(storageError.path)")
            }
            
            throw Errors.decodingHasNotSucceeded
            
        } catch {
            
            throw error
            
        }
        
    }
    
    public enum Errors: Error {
        
        /// Thrown if the decoding process hasn't succeeded.
        case decodingHasNotSucceeded
        
    }
    
}
