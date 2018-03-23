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

public protocol MetaSupplier {
    
    // MARK: containers
    
    /**
     Returns an empty `KeyedContainerMeta`.
     
     This method lets you use a custom container type (e.g. NSDictionary), if required.
     However this method has a default implementation returning a new DictionaryKeyedContainerMeta every time it is called.
     
     - Returns: A new, empty KeyedMetaContainer.
     - Attention: You should implement this method or keep the default implementation of it, even if you do not support keyed containers in you framework, because the documentation of Encodable specifies an empty keyed container as substitute if a value requested a single value container but did not encode anything. Do not use precondition or assert in this method for that reason. Also keyed containers are an important part of many `encode(to:)` implementations (especially the default generated ones). Therefor it could make sence to implement some transition from keyed containers to other containers you provide. A custom implementation of `KeyedContainerMeta` is the right
         place for this.
     */
    func keyedContainerMeta() -> KeyedContainerMeta
    
    /**
     Returns an empty `UnkeyedMetaContainer`.
     
     This method lets you use a custom container type (e.g. NSArray), if required.
     However this method has a default implementation returning a new ArrayUnkeyedContainerMeta every time it is called.
     
     - Returns: A new, empty UnkeyedMetaContainer.
     */
    func unkeyedContainerMeta() -> UnkeyedContainerMeta
    
    // see Meta/MetaSupplier+Defaults for default implementations
    
    // MARK: wrapper
    
    /**
     Creates sets and returns a `Meta` for the given value, or returns nil if the value is not supported, respectively can not be represented in your underlying format.
     
     This method will be called very frequently.
     
     This method will be asked to return a Meta for an instance of the type GenericNil from MetaSerialization for any nil value that is requested to be encoded. Return nil, if you don't support nil values. If you support nil values, you are invited to use NilMeta from MetaSerialization, but you may of course use any implementation here.
     - Parameter value: The value for which a wrapping meta should be returned.
     - Parameter codingPath: The coding path (this an array of coding keys visited up to value in the order they were visited) taken up to value. codingPath is ment to be used in errors you may throw (e.g. `EncodingError`).
     - Returns: nil or a `Meta` which wrappes value.
     */
    func wrap<T>(for value: T, at codingPath: [CodingKey]) throws -> Meta?
    
}
