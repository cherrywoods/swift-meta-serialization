//
//  MetaSupplier.swift
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
 The core interface to specify MetaEncoder's encoding.
 Implement this protocol to set encoding "primities"
 (these are usually the types you can represent directly in your serialization format)
 and container implementations. 
 */
public protocol MetaSupplier {
    
    // MARK: containers
    
    /**
     Returns an empty `EncodingKeyedContainerMeta`.
     
     This method lets you use a custom container type (e.g. NSDictionary), if required.
     However this method has a default implementation returning a new Dictionary<String, Meta> every time it is called.
     (Please note that currently all dictionarys conform to `KeyedContainerMeta` because it is currently not possible to use conditional conformance here since swift isn't able to check for conditional conformance at runtime right now. If you are using another Dictionary then Dictionay<String, Meta> as keyed container meta, your code will crash).
     
     - Returns: A new, empty EncodingKeyedMetaContainer.
     - Attention: You should implement this method or keep the default implementation of it, even if you do not support keyed containers in you framework, because the documentation of Encodable specifies an empty keyed container as substitute if a value did not encode anything. Do not use precondition or assert in this method for that reason. Also keyed containers are an important part of many `encode(to:)` implementations (especially the default generated ones). Therefor it could make sence to implement some transition from keyed containers to other containers you provide. A custom implementation of `KeyedContainerMeta` is the right place for this.
     */
    func keyedContainerMeta() -> EncodingKeyedContainerMeta
    
    /**
     Returns an empty `EncodingUnkeyedMetaContainer`.
     
     This method lets you use a custom container type (e.g. NSArray), if required.
     However this method has a default implementation returning a new Array<Meta> every time it is called.
     (Please note that currently all arrays conform to `UnkeyedContainerMeta` because it is currently not possible to use conditional conformance here since swift isn't able to check for conditional conformance at runtime right now. If you are using another Array then Array<Meta> as unkeyed container meta, your code will crash).
     
     - Returns: A new, empty EncodingUnkeyedMetaContainer.
     */
    func unkeyedContainerMeta() -> EncodingUnkeyedContainerMeta
    
    // see Meta/MetaSupplier+Defaults for default implementations
    
    // MARK: wrapper
    
    /**
     Creates, sets and returns a `Meta` for the given value, or returns nil if the value is not supported, respectively can not be represented in your underlying format.
     
     This method will be asked to return a Meta for an instance of the type NilMarker from MetaSerialization if encoding a nil value is requested.
     Return nil if you don't support nil values. If you support nil values, you are invited to use NilMarker itself as Meta, but you may of course use any meta implementation here.
     
     You may not call Encodables `encode(to:)` in this method directly, or otherwise call container methods.
     Calling these methods will conflict with the encoding of value, since you can not access the metas you created with those calls.
     Call `encoder.encode` instead and nest your container requests inside a utility type if necessary.
     
     This method is called very frequently.
     
     - Parameter value: The value for which a wrapping meta should be returned.
     - Parameter encoder: The encoder that requests the wrap. You should use this encoder if you need to encode values yourself inside wrap or to get the current coding path (this an array of coding keys visited up to value in the order they were visited) taken up to value. It is ment to be used in errors you may throw (e.g. `EncodingError`).
     - Returns: nil or a `Meta` which wrappes value.
     */
    func wrap<T>(_ value: T, for encoder: MetaEncoder) throws -> Meta?
    
}
