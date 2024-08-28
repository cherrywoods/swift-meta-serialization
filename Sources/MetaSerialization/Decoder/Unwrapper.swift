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
 Implement this protocol to unwrap "primities" (these are usually the types you can represent directly in your serialization format).
 
 A MetaDecoder will call `unwrap` for each meta in the meta tree before decoding takes place for it.
 There are actually two situations in which this happens.
 A MetaDecoder asks it's unwrapper to unwrap a meta to a concrete type (like String, Int, etc.).
 It does so by calling `unwrap` with a concrete type conforming to `Decodable`. `
 If you return nil in this method, the MetaDecoder will call `init(from:)` on the passed type.
 
 However, MetaDecoder will also try to unwrap metas to `NilMeta`, `DecodingKeyedContainerMeta` and `DecodingUnkeyedContainerMeta`.
 These options enables you to partially postpone the creation of the meta tree until the actual containers are known.
 
 Specifically, if keyed or unkeyed containers are requested for a meta from a MetaDecoder,
 before this meta is interpreted as keyed or unkeyed container and it is expected that it conforms to `DecodingKeyedContainerMeta` respectively `DecodingUnkeyedContainerMeta`,
 the decoder calls `unwrap`, with eigther `DecodingKeyedContainerMeta` or `DecodingUnkeyedContainerMeta` for type.
 If `unwrap` returns nil, the process continues with the original meta.
 
 With this, you may dynamically extend your meta tree.
 You don't need to know which meta will be a keyed or unkeyed container before MetaDecoder does it's work
 and don't need meta implementations to conform to `Decoding(Un)KeyedContainerMeta` or `NilMeta` if they could be seen as such containers or nil.
 
 For these three `unwrap` variants (where `type = NilMeta.Protocol`, `type = DecodingKeyedContainerMeta.Protocol` or `type = DecodingUnkeyedContainerMeta.Protocol`), there are default implementations provided, that always return nil.
 If you don't override these methods, a meta tree is expected to be "static",
 which means that all container types and nil values need to be known before `decode` on a MetaDecoder is called.
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
    
    // MARK: dynamically unwind meta stack
    
    /**
     Unwraps meta to a `NilMeta`.
     
     Returning nil in this method will make MetaDecoder try to interpret meta itself as `NilMeta`.
     Therefor, if meta does conform to `NilMeta` you do not need to handle it in this method.
     
     - Note: You may not throw in this method, in diffrence to the other methods.
     
     - Parameter meta: The meta you should unwrap to a nil meta. This meta was created by you and passed to a MetaDecoder.
     - Parameter decoder: The decoder that requests the unwrap. You should use this decoder if you need to decode types yourself inside unwrap or to get the current coding path (this an array of coding keys visited up to meta in the order they were visited) taken up to meta. This coding path is ment to be used in errors you may throw (e.g. `DecodingError`).
     - Returns: A `NilMeta` that was constructed from meta. Returns nil, if meta can not be converted to a nil meta.
     */
    func unwrap(meta: Meta, toType: NilMeta.Protocol, for decoder: MetaDecoder) -> NilMeta?
    
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


public extension Unwrapper {
    
    func unwrap(meta: Meta, toType: NilMeta.Protocol, for decoder: MetaDecoder) -> NilMeta? {
        return nil
    }
    
    func unwrap(meta: Meta, toType: DecodingKeyedContainerMeta.Protocol, for decoder: MetaDecoder) throws -> DecodingKeyedContainerMeta? {
        return nil
    }
    
    func unwrap(meta: Meta, toType: DecodingUnkeyedContainerMeta.Protocol, for decoder: MetaDecoder) throws -> DecodingUnkeyedContainerMeta? {
        return nil
    }
    
}
