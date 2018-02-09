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
public protocol Meta {
    
    /**
     sets the value of the meta
     - Throws: Throw an error if the given value has a invalid configuration and can not be stored by this meta. This does not mean, that you should throw an error, if the given type does not match the type you expected. This would represent a bug eigther in your framework or in meta-serialization itself. Rather than that throw an error, if the given value is out of range or has a special value you do not support and you do also not wrap to another type (Float.infinity could be such a case in JSON).
     */
    mutating func set(value: Any) throws
    /// returns the metas value. This may be nil, if the Meta has not been handled by a MetaEncoder or MetaDecoder, but if a Meta is passed to your Translator in encode() or decode() this value should not be nil, otherwise you dicovered a but in meta-serialization.
    func get() -> Any?
    
}

/**
 Protocol for metas indicating null/nil or no value contained
 Please note that there's a implementation `NilMeta` procided the by meta-serialization framework.
 */
public protocol NilMetaProtocol: Meta {  }

/**
 A subprotocol of Meta, enabeling you to rely on a specfic type, so you don't need to check for this type all the time
 
 meta-serialization provides default implementations for set(value:) and get(). set(value:) will crash (using the precodingtion method) the programm if a value with the wrong type is passed to set(value:). However, meta-serialization will never do this, unless you do not implement wrappingMeta(forSwiftType:) in your implementation of Translator with faults.
 */
public protocol GenericMeta: Meta {
    associatedtype SwiftValueType
    var value: SwiftValueType! { get set }
}

public extension GenericMeta {
    /// sets this GenericMetas value, if value has the required type (otherwise it will crash the programm, respectively produce an error during unit testing)
    mutating public func set(value: Any) {
        precondition(value is SwiftValueType, "Called set(value:) with invalid type")
        self.value = value as? SwiftValueType
    }
    
    public func get() -> Any? {
        return value as Any?
    }
}
