//
//  Unwrapper.swift
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

public protocol Unwrapper {
    
    /**
     Extracts a swift value of type T from a `Meta` you passed as part of a meta tree to a `MetaDecoder`.
     
     If you don't support the requested type directly (can't convert meta's value to T), return nil.
     
     If you decoded to a Meta conforming to NilMetaProtocol, that Meta will not reach your method.
     
     This method will be called very frequently.
     
     This method will be called for every meta of the meta tree you created.
     - Throws: If you throw a `DecodingError` in this method, MetaDecoder will replace the coding path of the `DecodingError.Context` with the actual coding path. You may therefor just use `[]` as coding path.
     - Parameter type: The type you should cast to.
     - Parameter meta: The meta whose value you should cast to T. This meta was created by you during decode.
     - Parameter decoder: The decoder that requests the unwrap. You should use this decoder if you need to decodetypes yourself inside unwrap or to get the current coding path (this an array of coding keys visited up to meta in the order they were visited) taken up to meta. codingPath is ment to be used in errors you may throw (e.g. `DecodingError`).
     - Returns: A value of type T, that was constructed from meta. Returns nil, if the requested type is not supported directly.
     */
    func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T?
    
}
