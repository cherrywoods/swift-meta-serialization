//
//  Translator.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
     Creates, sets and returns a new empty Meta with the given value, or returns nil, if the value is not supported, respectively can not be translated by this translator.
     
     This method will be called very frequently.
     
     This method will be asked to return a Meta for an instance of the type GenericNil from this framework for any nil value that is requested to be encoded. Return nil, if you don't support nil values. If you support nil values, you are invited to use NilMeta from MetaSerialization, but you may use any implementation here.
     - Parameter value: The value for which a wrapping Meta should be returned.
     - Returns: Nil or a Meta which was set to value.
     */
    func wrappingMeta<T>(for value: T) -> Meta?
    
    /**
     Extracts a swift value of type T from a meta you created during decode.
     If you don't support the requested type directly (can't convert meta's value to T), return nil.
     If you decoded to a Meta conforming to NilMetaProtocol, that Meta will not reach your method.
     
     In difference from the call of decode(), now the final type is known.
     
     This method will be called for every meta you created.
     - Throws: If you throw a `DecodingError` in this method, MetaDecoder will replace the coding path of the `DecodingError.Context` with the actual coding path. You may therefor just use `[]` as coding path.
     - Parameter T: The type you should cast to.
     - Parameter meta: The meta whose value you should cast to T. This meta was created by you during decode.
     - Returns: A value of type T, that was contained in meta. Returns nil, if the requested type is not supported directly.
     */
    func unwrap<T>(meta: Meta, toType type: T.Type) throws -> T?
    
    // MARK: - coding
    
    /**
     Encodes the given meta representation of any encodable type to your (raw) representation type.
     - Parameter Raw: the type that you will return. This parameter will be set by the frontend serialization implementeation you write. Therefor you may check for this type to be the one you expect and use the precondition function, to check whether your code works, or just cast directly using as!, but in these case you will get an uglier error message, if your code is faulted.
     - Parameter meta: The meta representation of any encodable swift value
     - Returns: The (raw) representation of the meta representation
     - Throws: Any error you throw will be directly propagated.
     */
    func encode<Raw>(_ meta: Meta) throws -> Raw
    
    /**
     Decodes the given (raw) representation to a meta representation. You need to use a Meta extending NilMetaProtocol, to indicate that a value was nil (You're invited to use NilMeta from MetaSerialization).
     - Parameter Raw: the type from that a value will be passed to you. This parameter will be set by the frontend serialization implementeation you write. Therefor you may check for this type to be the one you expect and use the precondition function, to check whether your code works, or just cast using as!, but in these case you will get a uglier error message, if your code is faulted.
     - Parameter raw: A (raw) representation value
     - Returns: The meta representation of the (raw) representation, if it was valid
     - Throws: Any error you throw will be directly propagated.
     */
    func decode<Raw>(_ raw: Raw) throws -> Meta
    
}

// MARK: default implementations for containers

public extension Translator {
    
    // TODO: upgrade when these containers are rewritten. Also update documenation above.
    
    public func keyedContainerMeta() -> KeyedContainerMeta {
        return DictionaryKeyedContainerMeta()
    }
    
    public func unkeyedContainerMeta() -> UnkeyedContainerMeta {
        return ArrayUnkeyedContainerMeta()
    }
    
}

