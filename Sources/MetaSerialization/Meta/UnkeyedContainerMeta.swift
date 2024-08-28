//
//  UnkeyedContainerMeta.swift
//  MetaSerialization
//  
//  Copyright 2018-2024 cherrywoods
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

public protocol UnkeyedContainerMeta: EncodingUnkeyedContainerMeta, DecodingUnkeyedContainerMeta {}

extension UnkeyedContainerMeta {
    
    public var numberOfMetasIfKnown: Int? {
        return numberOfMetas
    }
    
}

public protocol EncodingUnkeyedContainerMeta: Meta {
    
    /// The number of elements in the container (0 if no element is contained).
    var numberOfMetas: Int { get }
    
    /**
     Returns the element at the given index or nil, if the index is smaller than 0 or larger or equal than count.
     */
    func get(at index: Int) -> Meta?
    
    /**
     Inserts or appends the given Meta at index.
     Index may be equals count (in this case you should append), but not larger.
     */
    mutating func insert(_ meta: Meta, at index: Int)
    
}

public protocol DecodingUnkeyedContainerMeta: Meta {
    
    /**
     The number of Metas in the container, if this number is known.
     
     Returns nil, if the number is unknown.
     */
    var numberOfMetasIfKnown: Int? { get }
    
    /**
     Returns the element at the given index or nil, if the index is smaller than 0 or larger or equal than count.
     */
    func get(at index: Int) -> Meta?
    
}
