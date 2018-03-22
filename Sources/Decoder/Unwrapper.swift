//
//  Unwrapper.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See https://www.unlicense.org
// 

import Foundation

public protocol Unwrapper {
    
    /**
     Extracts a swift value of type T from a `Meta` you passed as part of a meta tree to a `MetaDecoder`.
     
     If you don't support the requested type directly (can't convert meta's value to T), return nil.
     
     If you decoded to a Meta conforming to NilMetaProtocol, that Meta will not reach your method.
     
     This method will be called for every meta of the meta tree you created.
     - Throws: If you throw a `DecodingError` in this method, MetaDecoder will replace the coding path of the `DecodingError.Context` with the actual coding path. You may therefor just use `[]` as coding path.
     - Parameter type: The type you should cast to.
     - Parameter meta: The meta whose value you should cast to T. This meta was created by you during decode.
     - Parameter codingPath: The coding path (this an array of coding keys visited up to meta in the order they were visited) taken up to meta. codingPath is ment to be used in errors you may throw (e.g. `DecodingError`).
     - Returns: A value of type T, that was constructed from meta. Returns nil, if the requested type is not supported directly.
     */
    func unwrap<T>(meta: Meta, toType type: T.Type, at codingPath: [CodingKey]) throws -> T?
    
}
