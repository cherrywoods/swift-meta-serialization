//
//  ConditionalEncodingMetaEncoder.swift
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
 A subclass of `MetaEncoder` that supports conditional encoding.
 
 Be sure to use this classes `encode` method to encode your top level object and resolve conditional encodings. Otherwise the resulting meta object will be invalid.
 
 Please note that for this task it maintains a list of all encoded instances of classes and performs a search for conditionally encoded objects on it. Due to this it requires more memory and more time. The memory overhead is independent of the use of `encodeConditional`.
 */
open class ConditionalEncodingMetaEncoder: MetaEncoder {
    
    // TODO: implement everything in a MetaSupplier
    
    private let payloadMap = ConditionalEncodingPayloadIdentityMap<[CodingKey]>()
    private let conditionallyEncodedObjects = ConditionalEncodingPayloadIdentityMap<ContainerElementReference>()
    
    override open func wrapConditional<E>(_ object: E, at key: CodingKey) throws -> Meta where E : AnyObject, E : Encodable {
        // TODO: implement
        return try wrap(object, at: key)
    }
    
    open func resolveConditionals() {
        // TODO: check list of conditionals against recorded payload. 
    }
    
}
