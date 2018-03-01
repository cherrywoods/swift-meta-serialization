//
//  MetaEncoder+frontend.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation

public extension MetaEncoder {
    
    /**
     Encodes the given value.
     
     Use this method rather than directly calling encode(to:).
     encode(to:) will not detect types in the first place
     that are directly supported by the translator.
     
     Example: If data is a Data instance and the translator supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded the way Data encodes itself.
     
     - Throws: Aside from any errors that are thrown of translator.encode and any `EncodingError` that has been thrown by another entitly, this function will throw  MetaEncoder.Errors.encodingHasNotSucceeded if the encoding could not succeed. This may happen due to illegal encoding behaviors, as requesting two diffrent containers at the same coding path, or a bug in MetaEncoder itself (or the used subclass, if used).
     */
    public func encode<E, Raw>(_ value: E) throws -> Raw where E: Encodable {
        
        // encode over wrap function
        // this will keep E from encoding itself,
        // if it is supported by translator
        
        do {
            
            let meta = try wrap(value)
            return try translator.encode(meta)
            
        } catch let storageError as CodingStorageError {
            
            switch (storageError.reason) {
            case .alreadyStoringValueAtThisCodingPath: assertionFailure("Illegal encode: Double store at coding path: \(storageError.path)")
            case .pathNotFilled: assertionFailure("Misuse of CodingStorage: path not filled: \(storageError.path)")
            case .noMetaStoredAtThisCodingPath: assertionFailure("Misuse of CodingStorage: expected stored meta at path: \(storageError.path)")
            case .pathIsLocked: assertionFailure("Misuse of CodingStack: path is locked: \(storageError.path)")
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
