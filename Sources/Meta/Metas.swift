//
//  MetaContainers.swift
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
 A container wrapping a certain value.
 This container is used at the meta or in between stage of encoding and decoding that MetaSerialization performs.
 */
public protocol Meta {}

/**
 Protocol for metas indicating null/nil or no value contained.
 Please note that MetaSerializations `NilMarker` type is an default implementation of this protocol.
 */
public protocol NilMeta: Meta {}

// TODO: remove GenericMeta (not necessary?)

/**
 A subprotocol of Meta with a specific value and value type.
 */
public protocol GenericMeta: Meta {
    
    associatedtype SwiftValueType
    
    var value: SwiftValueType { get }
    init(value: SwiftValueType)
    
}
