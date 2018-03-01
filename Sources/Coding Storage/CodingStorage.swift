//
//  CodingStorage.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

public enum CodingStorageError: Error {
    
    /// Thrown if there's already a value stored a the given path.
    case alreadyStoringValueAtThisCodingPath
    
    /// Thrown if a meta was tried to be inserted for a coding path with more than one new key.
    case pathNotFilled
    
    /// Thrown if no meta is stored at the requested coding path.
    case noMetaStoredAtThisCodingPath
    
    /// Thrown if a meta can not be removed, because the path is locked.
    case pathIsLocked
    
    
}

/**
 CodingStorage is the central storing unit of encoding as wall as decoding.
 
 It stores metas at coding paths (arrays of coding keys). Note that `[]` is also a valid path.
 
 The way how it stores them is implementation dependant and is correlated with the general abilities MetaSerialization can supply.
 
 In general, a single MetaEncoder or MetaDecoder will store and remove metas in a strictly linear manner.
 This means that this workflow is followed:
 
 store -> (lock) -> this workflow nested -> this workflow nested -> ... -> this workflow nested -> (unlock) -> remove
 
 Lock and unlock are optional and may not aloways be performed.
 However multiple encoders/decoders can work on a single storage.
 This also depends on your implementation.
 All new encoders/decoders will call fork and use the storage returned by it.
 */
public protocol CodingStorage {
    
    /**
     Returns whether the the storage 'is tidied up'.
     This is the case, if storage holds exactly one meta.
     
     A state like this typically indicated sucessfull encoding (and is used to check exactly this).
     */
    var hasMultipleMetasInStorage: Bool { get }
    
    /**
     Accesses the meta at the given coding path.
     
     You may not expect that you already stored a meta at codingPath.
     However you may expect, that the path up to codingPath[0..<codingPath.endIndex-1].
     */
    subscript (codingPath: [CodingKey]) -> Meta { get set }
    
    /**
     Returns whether a meta is stored at the coding path.
     
     If a placeholder was requested for this path, return false.
     
     If this function returns true for a certain path, it must be safe to subscript to this path.
     */
    func storesMeta(at codingPath: [CodingKey]) -> Bool
    
    /**
     Stores a new meta at the coding path.
     
     If there's currently a placeholder at the given path, replace the placeholder.
     
     The added coding path is by default unlocked.
     
     Throw CodingStorageErrors:
      - `.alreadyStoringValueAtThisCodingPath` if the storage already stores a meta at the given coding path
      - `.pathNotFilled` if there is no meta present for codingPath[0..<lastIndex-1]
     
     - Throws: `CodingStorageError`
     */
    func store(meta: Meta, at codingPath: [CodingKey]) throws
    
    /**
     Store a placeholder at the coding path.
     
     Throw CodingStorageErrors:
     - `.alreadyStoringValueAtThisCodingPath` if the storage already stores a meta at the given coding path
     - `.pathNotFilled` if there is no meta present for codingPath[0..<lastIndex-1]
     
     - Throws: `CodingStorageError`
     */
    func storePlaceholder(at codingPath: [CodingKey]) throws
    
    /**
     Remove the meta at the given coding path.
     
     Return nil, if a placeholder is stored at the path.
     
     Throw CodingStorageErrors:
     - `.noMetaStoredAtThisCodingPath` if no meta is stored at this coding path.
     - `.pathIsLocked` if you can not remove the meta at this coding path, because it is locked.
     
     - Throws: `CodingStorageError`
     */
    func remove(at codingPath: [CodingKey]) throws -> Meta?
    
    /**
     Lock the given coding path.
     
     This means that the meta associated with the given coding path may not be removed. It may still be set.
     You do not need to lock the whole coding path up to the given path, just exactly this coding path.
     
     Placeholders at this path may still be replaced.
     
     If path is already locked, do nothing.
     
     Throw CodingStorageErrors:
     - `.noMetaStoredAtThisCodingPath` if no meta is stored at this coding path.
     
     - Throws: `CodingStorageError`
     */
    func lock(codingPath: [CodingKey]) throws
    
    /**
     Unlock the given coding path.
     
     This means that after the call of this method the meta associated with the given coding path can be removed again.
     
     If you do not store a value at the given path, don't do anything.
     */
    func unlock(codingPath: [CodingKey])
    
    /**
     Return a CodingStoreage an new (super) encoder/decoder can work on.
     
     This new storage needs to be able to coop with coding paths for which values are stored in the
     storage fork is called on, but not in them teirselves.
     
     This means, that it is legitimate to call store(... at: [a, b, c]) on the storage returned by this function,
     if [a, b] was passed to fork, although there are not metas for [], [a] and [a, b] in the returned stroage.
     Accessing paths below the given coding path may fail.
     */
    func fork(at codingPath: [CodingKey]) -> CodingStorage
    
}
