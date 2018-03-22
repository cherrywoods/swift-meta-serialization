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
     Encodes the given value to a meta tree.
     
     Use this method rather than directly calling encode(to:) of `Encodable`.
     encode(to:) will not detect types in the first place
     that are directly supported by the `MetaSupplier`.
     
     Example: If data is a Data instance and the `MetaSupplier` supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded the way Data encodes itself.
     
     - Throws: Aside from any errors that are thrown of metaSupplier.wrap and any `EncodingError` that has been thrown by another entity, this function will throw `MetaEncoder.Errors.encodingHasNotSucceeded` if the encoding could not succeed. In general, this error will never be thrown in code running unter the debug (and not the release) configuration. Instead the call will fail with an assertion failure.
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
