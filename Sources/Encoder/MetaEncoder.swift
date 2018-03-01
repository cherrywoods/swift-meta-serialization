//
//  MetaCoder.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

// encoder will create a meta object

/// An Encoder that constucts a Meta format insted of encoding directly to the desired format
open class MetaEncoder: Encoder {
    
    // MARK: - general properties
    
    open var userInfo: [CodingUserInfoKey : Any]
    
    open var codingPath: [CodingKey]
    
    // MARK: - translator
    
    /// The translator used to get and finally translate Metas
    open let translator: Translator
    
    // MARK: - storage
    
    // use this StorageAccessor construction to give lock and unlock some sence
    
    /// A StorageAccessor to this encoder's storage
    private(set) open var storage: StorageAcessor
    
    /**
     StorageAccessor makes the storage of an encoder accessable up to some limit.
     */
    public struct StorageAcessor {
        
        private var storage: CodingStorage
        
        // MARK: - publicly accessable methods and subscripts
        
        /**
         Accesses the meta at the given coding path.
         
         You may not expect that you already stored a meta at codingPath.
         However you may expect, that the path up to codingPath[0..<codingPath.endIndex-1].
         */
        subscript (codingPath: [CodingKey]) -> Meta {
            
            get {
                
                return storage[codingPath]
                
            }
            
            set {
                
                storage[codingPath] = newValue
                
            }
            
        }
        
        /**
         Returns whether a meta is stored at the coding path.
         
         If this function returns true for a certain path, it is safe to subscript to this path.
         */
        public func storesMeta(at codingPath: [CodingKey]) -> Bool {
            
            return storage.storesMeta(at: codingPath)
            
        }
        
        /**
         Store a placeholder at the coding path.
         
         If there's currently a placeholder stored at the given path, replaces the placeholder.
         
         Throw CodingStorageErrors:
         - `.alreadyStoringValueAtThisCodingPath` if the storage already stores a meta at the given coding path
         - `.pathNotFilled` if there is no meta present for codingPath[0..<lastIndex-1]
         
         - Throws: `CodingStorageError`
         */
        func storePlaceholder(at codingPath: [CodingKey]) throws {
            
            try storage.storePlaceholder(at: codingPath)
            
        }
        
        /**
         Stores a new meta at the coding path.
         
         Throws CodingStorageErrors:
         - `.alreadyStoringValueAtThisCodingPath` if the storage already stores a meta at the given coding path
         - `.pathNotFilled` if there is no meta present for codingPath[0..<lastIndex-1]
         
         - Throws: `CodingStorageError`
         */
        public func store(meta: Meta, at codingPath: [CodingKey]) throws {
            
            try storage.store(meta: meta, at: codingPath)
            
        }
        
        /**
         Remove the meta at the given coding path.
         
         Returns nil, if a placeholder is stored at the path.
         
         Throws CodingStorageErrors:
         - `.noMetaStoredAtThisCodingPath` if no meta is stored at this coding path.
         - `.pathIsLocked` if you can not remove the meta at this coding path, because it is locked.
         
         - Throws: `CodingStorageError`
         */
        public func remove(at codingPath: [CodingKey]) throws -> Meta? {
            
            return try storage.remove(at: codingPath)
            
        }
        
        /**
         Returns a CodingStoreage an new (super) encoder/decoder can work on.
         
         This new storage will be able to store at paths beyond the passed codingPath.
         Accessing paths below the given coding path may fail.
         */
        func fork(at codingPath: [CodingKey]) -> CodingStorage {
            
            return storage.fork(at: codingPath)
            
        }
        
        // MARK: fileprivates
        
        fileprivate init(with storage: CodingStorage) {
            
            self.storage = storage
            
        }
        
        /// locks the given coding path
        fileprivate func lock(codingPath: [CodingKey]) throws {
            
            try storage.lock(codingPath: codingPath)
            
        }
        
        /// unlocks the given coding path
        fileprivate func unlock(codingPath: [CodingKey]) {
            
            storage.unlock(codingPath: codingPath)
            
        }
        
    }
    
    // MARK: initalizers
    
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
        self.storage = StorageAcessor(with: storage)
        
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
        defer { _ = try? storage.remove(at: path) }
        
        try storage.lock(codingPath: path)
        
        // let value encode itself to this encoder
        try value.encode(to: self)
        
        storage.unlock(codingPath: path)
        
        // if value requests no container,
        // we are promted by the documention of Encodable to encode an empty keyed container
        return try storage.remove(at: path) ?? translator.keyedContainerMeta()
        
    }
    
    // MARK: container(referencing:) methods
    
    /**
     Creates a new keyed container meta, sets reference.meta to this new meta and then returns a new MetaKeyedEncodingContainer referencing reference.
     */
    open func container<Key: CodingKey>(keyedBy keyType: Key.Type, referencing reference: Reference, at codingPath: [CodingKey]) -> KeyedEncodingContainer<Key> {
        
        var reference = reference
        reference.meta = translator.keyedContainerMeta()
        
        return KeyedEncodingContainer( MetaKeyedEncodingContainer<Key>(referencing: reference,
                                                                       at: codingPath,
                                                                       encoder: self) )
        
    }
    
    /**
     Creates a new unkeyed container meta, sets reference.meta to this new meta and then returns a new MetaKeyedEncodingContainer referencing reference.
     */
    open func unkeyedContainer(referencing reference: Reference, at codingPath: [CodingKey]) -> UnkeyedEncodingContainer {
        
        var reference = reference
        reference.meta = translator.unkeyedContainerMeta()
        
        return MetaUnkeyedEncodingContainer(referencing: reference,
                                            at: codingPath,
                                            encoder: self)
        
    }
    
    /**
     Creates a new single value container meta, sets reference.meta to this new meta and then returns a new MetaKeyedEncodingContainer referencing reference.
     */
    open func singleValueContainer(referencing reference: Reference, at codingPath: [CodingKey]) -> SingleValueEncodingContainer {
        
        return MetaSingleValueEncodingContainer(referencing: reference,
                                                at: codingPath,
                                                encoder: self)
        
    }
    
    // MARK: superEncoder
    
    /**
     Creates a new encoder that encodes to the given reference. This encoder can for example be used as super encoder.
     */
    open func encoder(referencing reference: Reference, at codingPath: [CodingKey]) -> Encoder {
        
        let referencingStorage = ReferencingCodingStorage(referencing: reference,
                                                          delegatingTo: storage.fork(at: codingPath),
                                                          at: codingPath)
        
        return MetaEncoder(at: codingPath,
                           with: userInfo,
                           translator: translator,
                           storage: referencingStorage)
        
    }
    
}
