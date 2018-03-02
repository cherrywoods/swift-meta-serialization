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
 A subprotocol of Meta with a specific value and value type. 
 */
public protocol GenericMeta: Meta {
    
    associatedtype SwiftValueType
    var value: SwiftValueType { get set }
    
}
