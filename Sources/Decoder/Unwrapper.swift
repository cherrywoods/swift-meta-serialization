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

/**
 The core interface to specify MetaDecoder's decoding.
 Implement this protocol to unwrap "primities"
 (these are usually the types you can represent directly in your serialization format).
 */
public protocol Unwrapper {
    
    /**
     Extracts a swift value of type T from a `Meta` you passed as part of a meta tree to a `MetaDecoder`.
     
     If you don't support the requested type directly (can't convert meta's value to T), return nil.
     
     If you decoded to a Meta conforming to NilMeta, that Meta will not reach your method.
     
     If on a `MetaDecoder` the option `MetaDecoder.Options.dynamicallyUnwindMetaTree` is set,
     the decoder will call `unwrap` with the types `DecodingKeyedContainerMeta` and `DecodingUnkeyedContainerMeta`.
     If you return nil for these containers, the meta passed to unwrap will be used as container meta, if it conforms to these types.
     Otherwise a DecodingError will be thrown.
     
     You may in this method directly call Decodables `init(from:)` if desired or access decoders container methods otherwise.
     However calling `decoder.decode(type:, from:)` is not allowed and will throw `MetaDecoder.Errors.decodingHasNotSucceeded`.
     If you called `init(from:)` or one of the container methods, you must eigther return a non-nil value,
     or the containers you requested need to align with the decoding code of T (doing this isn't recommended, return a value).
     
     This method is called very frequently.
     
     - Parameter meta: The meta you should unwrap to T. This meta was created by you and passed to a MetaDecoder.
     - Parameter type: The type you should unwrap to.
     - Parameter decoder: The decoder that requests the unwrap. You should use this decoder if you need to decode types yourself inside unwrap or to get the current coding path (this an array of coding keys visited up to meta in the order they were visited) taken up to meta. This coding path is ment to be used in errors you may throw (e.g. `DecodingError`).
     - Returns: A value of type T that was constructed from meta. Returns nil, if the requested type is not supported directly or meta not unwrappable to it.
     */
    func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? where T: Decodable
    
}

/**
 An extended unwrapper that supports dynamically unwinding the meta tree (see `MetaDecoder.Options.dynamicallyUnwindMetaTree`)
 */
public protocol ContainerUnwrapper: Unwrapper {
    
    /**
     Unwraps meta to a `DecodingKeyedContainerMeta`.
     
     Returning nil in this method will make MetaDecoder to try to interpret meta as `DecodingKeyedContainerMeta`.
     Therefor, if meta does conform to `DecodingKeyedContainerMeta` you do not need to handle it in this method.
     
     - Parameter meta: The meta you should unwrap to a keyed container meta. This meta was created by you and passed to a MetaDecoder.
     - Parameter decoder: The decoder that requests the unwrap. You should use this decoder if you need to decode types yourself inside unwrap or to get the current coding path (this an array of coding keys visited up to meta in the order they were visited) taken up to meta. This coding path is ment to be used in errors you may throw (e.g. `DecodingError`).
     - Returns: A `DecodingKeyedContainerMeta` that was constructed from meta. Returns nil, if meta can not be converted to a keyed container meta.
     */
    func unwrap(meta: Meta, toType: DecodingKeyedContainerMeta.Protocol, for decoder: MetaDecoder) throws -> DecodingKeyedContainerMeta?
    
    /**
     Unwraps meta to a `DecodingUnkeyedContainerMeta`
     
     Returning nil in this method will make MetaDecoder to try to interpret meta as `DecodingUnkeyedContainerMeta`.
     Therefor, if meta does conform to `DecodingUnkeyedContainerMeta` you do not need to handle it in this method.
     
     - Parameter meta: The meta you should unwrap to an unkeyed container meta. This meta was created by you and passed to a MetaDecoder.
     - Parameter decoder: The decoder that requests the unwrap. You should use this decoder if you need to decode types yourself inside unwrap or to get the current coding path (this an array of coding keys visited up to meta in the order they were visited) taken up to meta. This coding path is ment to be used in errors you may throw (e.g. `DecodingError`).
     - Returns: A `DecodingUnkeyedContainerMeta` that was constructed from meta. Returns nil, if meta can not be converted to an unkeyed container meta.
     */
    func unwrap(meta: Meta, toType: DecodingUnkeyedContainerMeta.Protocol, for decoder: MetaDecoder) throws -> DecodingUnkeyedContainerMeta?
    
}
