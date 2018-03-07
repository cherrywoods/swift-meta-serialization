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
     Decodes a value of type D from the given raw value.
     
     Use this method rather than directly calling Decodable.init(from:).
     init(from:) will not detect types that are directly supported by the translator.
     
     If this decoder wasn't freshly initalized, it may throw CodingStorageErrors.
     */
    public func decode<D, Raw>(type: D.Type, from raw: Raw) throws -> D where D: Decodable {
        
        do {
            
            let meta = try translator.decode(raw)
            
            // will store the decoded meta at the current path
            // if it isn't directly supported by the translator
            // this current path should be the root path [],
            // but in principle it is also possible to call this somewhere else
            return try unwrap(meta, toType: type)
            
        } catch let storageError as CodingStorageError {
            
            switch (storageError.reason) {
            case .alreadyStoringValueAtThisCodingPath: assertionFailure("Illegal decode: Double store at coding path: \(storageError.path)")
            case .pathNotFilled: assertionFailure("Misuse of CodingStorage: path not filled: \(storageError.path)")
            case .noMetaStoredAtThisCodingPath: assertionFailure("Misuse of CodingStorage: expected stored meta at path: \(storageError.path)")
            case .pathIsLocked: assertionFailure("Misuse of CodingStack: path is locked: \(storageError.path)")
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