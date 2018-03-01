//
//  ReferencingStorage.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation

/**
 A CodingStorage that writes the meta on it's base path back to another storage.
 
 This storage will writeback the meta stored to the base path to reference.
 */
open class ReferencingCodingStorage: CodingStorage {
    
    // MARK: properties
    
    open var reference: Reference
    open let basePath: [CodingKey]
    open var delegate: CodingStorage
    
    // MARK: init
    
    /**
     Creates a new ReferencingCodingStorage for base path that writes back to the given reference and uses storage as underlying delegate.
     
     storage needs to be able to store a meta at basePath.
     */
    public init(referencing reference: Reference, delegatingTo storage: CodingStorage, at basePath: [CodingKey] ) {
        
        self.reference = reference
        self.basePath = basePath
        self.delegate = storage
        
        // store placeholder and lock, so metas at base path can not be removed
        try! delegate.storePlaceholder(at: basePath)
        try! delegate.lock(codingPath: basePath)
        
    }
    
    // MARK: coding storage functionality
    
    open subscript(codingPath: [CodingKey]) -> Meta {
        
        get {
            
            return delegate[codingPath]
            
        }
        
        set {
            
            delegate[codingPath] = newValue
            
            // need to write back to reference,
            // if codingPath is the stored base path
            if codingPath == basePath {
                
                reference.meta = newValue
                
            }
            
        }
        
    }
    
    open func storesMeta(at codingPath: [CodingKey]) -> Bool {
        
        return delegate.storesMeta(at: codingPath)
        
    }
    
    open func store(meta: Meta, at codingPath: [CodingKey]) throws {
        
        try delegate.store(meta: meta, at: codingPath)
        
        // write back to reference, if codingPath is the base path
        if codingPath == basePath {
            
            reference.meta = meta
            
        }
        
    }
    
    open func storePlaceholder(at codingPath: [CodingKey]) throws {
        
        try delegate.storePlaceholder(at: codingPath)
        
    }
    
    open func remove(at codingPath: [CodingKey]) throws -> Meta? {
        
        // because we locked the base path in the costructor,
        // base path not not be removed
        return try delegate.remove(at: codingPath)
        
    }
    
    open func lock(codingPath: [CodingKey]) throws {
        
        try delegate.lock(codingPath: codingPath)
        
    }
    
    open func unlock(codingPath: [CodingKey]) {
        
        delegate.unlock(codingPath: codingPath)
        
    }
    
    open func fork(at codingPath: [CodingKey]) -> CodingStorage {
        
        let delegatesFork = delegate.fork(at: codingPath)
        
        if codingPath == basePath {
            
            let reference = Reference.direct(self, codingPath)
            return ReferencingCodingStorage(referencing: reference, delegatingTo: delegatesFork, at: codingPath)
            
        } else {
            
            return delegatesFork
            
        }
        
    }
    
}

/**
 Provide a == operator for coding paths
 */
fileprivate extension Array where Element == CodingKey {
    
    static func ==(lhs: [CodingKey], rhs: [CodingKey]) -> Bool {
        
        guard lhs.count == rhs.count else {
            // if paths do not have equal lengths, they can not be equal
            return false
        }
        
        var lhsKey: CodingKey, rhsKey: CodingKey
        
        // run through keys from the end to the start, to speed up the implementation
        // typically paths will match on the first keys but diverge later
        for index in (0..<lhs.count).reversed() {
            
            lhsKey = lhs[ lhs.startIndex.advanced(by: index) ]
            rhsKey = rhs[ rhs.startIndex.advanced(by: index) ]
            
            // compare by string values, asserting that their string values identify them
            guard lhsKey.stringValue == rhsKey.stringValue else {
                return false
            }
            
        }
        
        // if all keys matched (by string values) paths are seen as equal
        return true
        
    }
    
}
