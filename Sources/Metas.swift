//
//  MetaContainers.swift
//  meta-serialization
//
//  Created by cherrywoods on 15.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 A container wraping a certain value
 This container is used at the meta- or in between stage of coding, the meta-serialization framework performs
 */
public protocol Meta {}

/**
 Protocol for metas indicating null/nil or no value contained
 Please note that there's a implementation `NilMeta` procided the by meta-serialization framework.
 */
public protocol NilMetaProtocol: Meta {}

/**
 A subprotocol of Meta, enabeling you to rely on a specfic type, so you don't need to check for this type all the time
 
 meta-serialization provides default implementations for set(value:) and get(). set(value:) will crash (using the precodingtion method) the programm if a value with the wrong type is passed to set(value:). However, meta-serialization will never do this, unless you do not implement wrappingMeta(forSwiftType:) in your implementation of Translator with faults.
 */
public protocol GenericMeta: Meta {
    associatedtype SwiftValueType
    var value: SwiftValueType { get set }
}
