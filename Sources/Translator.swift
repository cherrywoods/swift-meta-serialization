//
//  Translator.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

public protocol Translator {
    
    // MARK: - meta serialization methods
    
    // MARK: containers
    
    /**
     Returns an empty KeyedMetaContainer.
     
     This method lets you use a custom container type (e.g. NSDictionary), if required.
     However this method has a default implementation returning a new DictionaryKeyedContainerMeta every time it is called.
     
     - Returns: A new, empty KeyedMetaContainer.
     - Attention: You should implement this method or keep the default implementation of it, even if you do not support keyed containers in you framework, because the documentation of Encodable specifies an empty keyed container as substitute if a value requested a single value container but did not encode anything. Do not use precondition or assert in this method for that reason.
     
         You may for example use the EmptyOnlyKeyedContainerMeta provided by meta-serialization, that will simply do nothing all the time
     */
    func keyedContainerMeta() -> KeyedContainerMeta
    
    /**
     Returns an empty UnkeyedMetaContainer.
     
     This method lets you use a custom container type (e.g. NSArray), if required.
     However this method has a default implementation returning a new ArrayUnkeyedContainerMeta every time it is called.
     
     - Returns: A new, empty UnkeyedMetaContainer.
     */
    func unkeyedContainerMeta() -> UnkeyedContainerMeta
    
    // MARK: wrapper
    
    /**
     Creates and returns a new empty Meta for the given type, or nil, if the given type is not supported, respectively can not be translated by this translator.
     This method will be called very frequently.
     This method will be asked to return an Meta for the type GenericNil from this framework for any nil value that is requested to be encoded or decoded. Return nil, if you don't support nil values. If you support Nil values, you are invited to use NilMeta from meta-serialization, however the Meta you return should conform to NilMetaProtocol.
     - Parameter forSwiftType: The SwiftType for wich a wrapping Meta should be returned.
     - Returns: A Meta that will wrap an instance of forSwiftType.
     */
    func wrapingMeta<T>(forSwiftType: T.Type) -> Meta?
    
    /**
     Extract the swift value from a meta, you initalized during decode(). If you don't support the requested type directly, return nil. If you decoded to a Meta conforming to NilMetaProtocol, that Meta will not reach your method.
     
     In difference from the call of decode(), now the final type is known.
     
     This method will be called for every meta you created.
     - Throws: If meta does not match the type you expect, throw a DecodingError.typeMismatch Error.
     - Parameter T: The type from swift you should cast to.
     - Parameter meta: The meta, that contains the value in some meta encoded form, that you should cast to T.
     - Returns: A value of type T, that was contained in meta. Returns nil, if the requested type is not supported directly.
     */
    func unwrap<T>(meta: Meta) throws -> T?
    
    // MARK: - coding
    
    /**
     Encodes the given meta representation of any encodable type to your (raw) representation type.
     - Parameter Raw: the type that you will return. This parameter will be set by the frontend serialization implementeation you write. Therefor you may check for this type to be the one you expect and use the precondition function, to check whether your code works, or just might cast directly using as!, but in these case you will get an uglier error message, if your code contains errors (mostly typos I guess).
     - Parameter meta: The meta representation of any encodable swift value
     - Returns: The (raw) representation of the meta representation
     - Throws: Throw an EncodingError, if the meta representation is invalid and can not be encoded by this translator
     */
    func encode<Raw>(_ meta: Meta) throws -> Raw
    
    /**
     Decodes the given (raw) representation to a meta representation. Use a Meta extending NilMetaProtocol, to indicate that a value was nil.
     - Parameter Raw: the type from that a value will be passed to you. This parameter will be set by the frontend serialization implementeation you write. Therefor you may check for this type to be the one you expect and use the precondition function, to check whether your code works, or just cast using as!, but in these case you will get a uglier error message, if your code contains errors (mostly typos I guess).
     - Parameter raw: A (raw) representation value
     - Returns: The meta representation of the (raw) representation, if it was valid
     - Throws: Throw an DecodingError, if the (raw) representation is invalid and can not be decoded by this translator
     */
    func decode<Raw>(_ raw: Raw) throws -> Meta
    
}

public extension Translator {
    
    // MARK: default implementations for containers
    public func keyedContainerMeta() -> KeyedContainerMeta {
        return DictionaryKeyedContainerMeta()
    }
    
    public func unkeyedContainerMeta() -> UnkeyedContainerMeta {
        return ArrayUnkeyedContainerMeta()
    }
    
}
