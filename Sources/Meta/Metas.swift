//
//  MetaContainers.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/**
 A container wrapping a certain value.
 This container is used at the meta or in between stage of encoding and decoding that MetaSerialization performs.
 */
public protocol Meta {}

/**
 Protocol for metas indicating null/nil or no value contained
 Please note that there's a default implementation (`NilMeta`) procided the by MetaSerialization.
 */
public protocol NilMetaProtocol: Meta {}

/**
 A subprotocol of Meta with a specific value and value type. 
 */
public protocol GenericMeta: Meta {
    
    associatedtype SwiftValueType
    var value: SwiftValueType { get }
    
}
