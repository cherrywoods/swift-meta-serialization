//
//  StorageAccessor.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation


/**
 StorageAccessor makes the storage of an encoder or decoder accessable up to some limit.
 
 The access is limited to prevent some encoding or decoding codes that manipulate storages
 in a destructive way.
 Alltough MetaSerialization can't stop you completely from modifying an encoders or decoders storage,
 you should definitelly not do it.
 
 MetaSerialization implements some restictions on what is possible,
 to prevent faults directly during serialization and not produce non debuggable data trash.
 */
public struct StorageAcessor {
    
    // MARK: - internals
    
    internal var storage: CodingStorage
    
    internal init(with storage: CodingStorage) {
        
        self.storage = storage
        
    }
    
    /// locks the given coding path
    internal func lock(codingPath: [CodingKey]) throws {
        
        try storage.lock(codingPath: codingPath)
        
    }
    
    /// unlocks the given coding path
    internal func unlock(codingPath: [CodingKey]) {
        
        storage.unlock(codingPath: codingPath)
        
    }
    
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
     Return a CodingStoreage an new (super) encoder/decoder can work on.
     
     This new storage needs to be able to coop with coding paths for which values are stored in the
     storage fork is called on, but not in them teirselves.
     
     This means, that it is legitimate to call store(... at: [a, b, c]) on the storage returned by this function,
     if [a, b] was passed to fork, although there are no metas stored for [], [a] and [a, b] in the returned stroage.
     Accessing paths below the given coding path may fail.
     */
    public func fork(at codingPath: [CodingKey]) -> CodingStorage {
        
        return storage.fork(at: codingPath)
        
    }
    
}
