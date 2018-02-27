//
//  MetaCoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 15.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

// encoder will create a meta object

/// An Encoder that constucts a Meta entity insted of encoding directly to the desired format
open class MetaEncoder: Encoder, MetaCoder {
    
    // MARK: - properties
    
    open var userInfo: [CodingUserInfoKey : Any]
    
    /// the CodingStack of this encoder
    open var storage: CodingStorage
    
    open var codingPath: [CodingKey]
    
    /// The translator used to get and finally translate Metas
    open let translator: Translator
    
    // MARK: - front end
    
    /**
     Encodes the given value.
     
     Use this method rather than directly calling encode(to:).
     encode(to:) will not detect types in the first place
     that are directly supported by the translator.
     
     Example: If data is a Data instance and the translator supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded the way Data encodes itself.
     */
    open func encode<E, Raw>(_ value: E) throws -> Raw where E: Encodable {
        
        // encode over wrap function
        // this will keep E from encoding itself,
        // if it is supported by translator
        
        // if value didn't encode an empty keyed container meta should be used
        // (according to the documentation of Encodable)
        let meta = try wrap(value)
        
        return try translator.encode(meta)
        
    }
    
    /**
     Initalizes a new MetaEncoder with the given values.
     
     - Parameter codingPath: The coding path this decoder will start at
     - Parameter userInfo: additional information to provide context during decoding
     - Parameter translator: The translator the decoder will use to translate Metas.
     - Parameter storage: A empty CodingStorage that should be used to store metas.
     */
    public init(at codingPath: [CodingKey] = [],
                with userInfo: [CodingUserInfoKey : Any] = [:],
                translator: Translator,
                storage: CodingStorage = LinearCodingStack() ) {
        
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.translator = translator
        self.storage = storage
        
    }
    
    // MARK: - wrap
    
    /// wraps an encodable value into a meta requested from translator.
    open func wrap<E>(_ value: E, at key: CodingKey? = nil) throws -> Meta where E: Encodable {
        
        // In difference to the old version, now stack
        // can also push a new meta, if the last meta is a
        // PlaceholderMeta.
        
        // This makes requesting a single value container
        // and then encoding a "single value" like an array
        // which failed in the old versions.
        // This is the same behavior as JSONEncoder from
        // Foundation shows.
        
        if key != nil { codingPath.append(key!) }
        defer{ if key != nil { codingPath.removeLast() } }
        
        // check whether translator supports value directly
        if let newMeta = self.translator.wrappingMeta(for: value) {
            
            // meta's value should be already set by translator
            return newMeta
            
        }
        
        // ** now the value's type is not supported natively by translator **
        
        /*
         Need to throw an error, if value is an Int, Int8, Int16, Int32, Int64, UInt, UInt8, UInt16, UInt32, UInt64, Float, Double, Bool or String
         but isn't supported by the translator,
         because if not, an endless callback would follow
         see Foundation Primitive Codables.swift for more information.
         
         The same applies for DirectlyEncodable.
         
         We also need to throw an error, if value is an GenericNil
         instance, because if we did not, nil values would encode
         as empty containers.
         
         All this is archieved by checking if value is DirectlyEncodable.
         All foundation's "primitive codables" (listed above) and GenericNil too are extended
         to implement DirectlyCodable.
         */
        
        guard !(value is DirectlyEncodable) else {
            
            let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "DirectlyEncodable value \(String(describing: value)) was not accepted by the Translator implementation.")
            throw EncodingError.invalidValue(value, context)
            
        }
        
        let path = self.codingPath
        
        try storage.storePlaceholder(at: path)
        // TODO: check whether this enables the same error behavior as decoder
        // defer { _ = try? storage.remove(at: path) }
        
        try storage.lock(codingPath: path)
        
        // let value encode itself to this encoder
        try value.encode(to: self)
        
        storage.unlock(codingPath: path)
        
        // if value requests no container,
        // we are promted by the documention of Encodable to encode an empty keyed container
        return try storage.remove(at: path) ?? translator.keyedContainerMeta()
        
    }
    
    // MARK: - container methods
    
    open func container<Key>(keyedBy keyType: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        
        // if there's no container at the current codingPath, let translator create a new one and store it
        // if there is one and it isn't a KeyedContainerMeta, throw an error
        
        if storage.isMetaStored(at: codingPath) {
            
            guard storage[codingPath] is KeyedContainerMeta else {
                preconditionFailure("Requested a second container at a previously used coding path.")
            }
            
        } else {
            
            // there is no container. Store a new one
            try! storage.store(meta: translator.keyedContainerMeta(), at: codingPath)
            
        }
        
        let reference = StorageReference(coder: self, at: codingPath)
        return KeyedEncodingContainer( MetaKeyedEncodingContainer<Key>(referencing: reference, codingPath: codingPath) )
        
    }
    
    open func unkeyedContainer() -> UnkeyedEncodingContainer {
        
        if storage.isMetaStored(at: codingPath) {
            
            guard storage[codingPath] is UnkeyedContainerMeta else {
                preconditionFailure("Requested a second container at a previously used coding path.")
            }
            
        } else {
            
            // there is no container. Store a new one
            try! storage.store(meta: translator.unkeyedContainerMeta(), at: codingPath)
            
        }
        
        let reference = StorageReference(coder: self, at: codingPath)
        return MetaUnkeyedEncodingContainer(referencing: reference, codingPath: codingPath)
        
    }
    
    open func singleValueContainer() -> SingleValueEncodingContainer {
        
        // A little bit strangely but not easily preventable,
        // a entity can request a keyed or unkeyed container
        // and then request a SingleValueContainer reffering to the meta of the keyed or unkeyed container.
        
        // if an entity tried to encode twice at the same path, the single value container will fail, but this function will succeed
        
        let reference = StorageReference(coder: self, at: codingPath)
        return MetaSingleValueEncodingContainer(referencing: reference, codingPath: codingPath)
        
    }
    
}
