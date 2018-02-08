//
//  UselessTranslator.swift
//  meta-serializationTests
//
//  Created by cherrywoodss on 26.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation
@testable import MetaSerialization

/// This translator does nothing. It translates to and from Metas.
class UselessTranslator: Translator {
    
    func wrappingMeta<T>(for value: T) -> Meta? {
        
        if T.self == GenericNil.self {
            return NilMeta()
        }
        
        return SimpleGenericMeta<T>() as Meta?
        
    }
    
    func unwrap<T>(meta: Meta, toType: T.Type) throws -> T? {
        
        // meta will be initalized (get() will not return nil)
        // and the value should be of type T.
        // if it is not throw typeMissmatch error
        guard let value = meta.get()! as? T else {
            throw TranslatorError.typeMismatch
        }
        
        return value
        
    }
    
    func encode<Raw>(_ meta: Meta) throws -> Raw {
        return try UselessTranslator.encodeToMeta( meta )
    }
    
    func decode<Raw>(_ raw: Raw) throws -> Meta {
        return try UselessTranslator.decodeFromMeta( raw )
    }
    
    static func encodeToMeta<Raw>(_ meta: Meta) throws -> Raw {
        precondition(Raw.self == Meta.self, "Incorrect translation type")
        return meta as! Raw
    }
    
    static func decodeFromMeta<Raw>(_ raw: Raw) throws -> Meta {
        precondition(Raw.self == Meta.self, "Incorrect translation type")
        return raw as! Meta
    }

    
}
