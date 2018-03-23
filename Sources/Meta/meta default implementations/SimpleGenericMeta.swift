//
//  SimpleGenericMeta.swift
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

/**
 A simple default implementation for metas that do only wrap another value.
 */
public struct SimpleGenericMeta<T>: GenericMeta {
    
    public typealias SwiftValueType = T
    
    /**
     The value this meta is wrapping.
     */
    public let value: T
    
    /**
     Init a new SimpleGenericMeta with the given value
     */
    public init(value: T) {
        self.value = value
    }
    
}
