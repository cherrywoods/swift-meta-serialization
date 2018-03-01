//
//  CodingHeap.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

// TODO: doc
open class CodingHeap: CodingStorage {
    
    /// stores metas for concatenations of string values of coding keys
    private var heap: Dictionary<String, Meta>
    
    /// stores the locked coding paths
    private var locks: Set<String>
    
    // MARK: coding path utilities
    
    /// converts a coding path to the internally used format
    private func concatCodingPath(_ path: Array<CodingKey>) -> String {
        
        return concatCodingPath( path[0..<path.endIndex] )
        
    }
    
    private func concatCodingPath(_ path: ArraySlice<CodingKey>) -> String {
        
        var result = "/"
        for key in path {
            result += convert(codingKey: key)
        }
        return result
        
    }
    
    private func convert(codingKey key: CodingKey) -> String {
        
        return "/\(key.stringValue)"
        
    }
    
    // MARK: initalization
    
    /// Initalizes a new empty CodingHeap.
    public required init() {
        
        heap = [:]
        locks = Set<String>()
        
    }
    
    // MARK: CodingStorage implementation
    
    public var hasMultipleMetasInStorage: Bool {
        
        return heap.count > 1
        
    }
    
    public subscript(path: [CodingKey]) -> Meta {
        
        get {
            
            return heap[ concatCodingPath(path) ]!
            
        }
        
        set {
            
            heap[ concatCodingPath(path) ] = newValue
            
        }
        
    }
    
    public func storesMeta(at codingPath: [CodingKey]) -> Bool {
        
        let converted = concatCodingPath(codingPath)
        let meta = heap[converted]
        // if meta is nil, there is no meta stored
        return meta != nil && !(meta is PlaceholderMeta)
        
    }
    
    public func store(meta: Meta, at codingPath: [CodingKey]) throws {
        
        let convertedPath: String
        
        if codingPath.count > 0 {
            
            // check containance of path, if path is not the root path []
            
            let lastPath = concatCodingPath( codingPath[0..<codingPath.endIndex-1] )
            
            guard heap[lastPath] != nil else {
                throw CodingStorageError.pathNotFilled
            }
            
            convertedPath = lastPath + convert(codingKey: codingPath.last!)
            
        } else {
            
            convertedPath = concatCodingPath(codingPath)
            
        }
        
        let old = heap[convertedPath]
        
        // guard that there was no value stored at this path before
        // or that a placeholder is stored there
        guard old == nil || old is PlaceholderMeta else {
            throw CodingStorageError.alreadyStoringValueAtThisCodingPath
        }
        
        heap[convertedPath] = meta
        
    }
    
    public func storePlaceholder(at codingPath: [CodingKey]) throws {
        
        try store(meta: PlaceholderMeta.instance, at: codingPath)
        
    }
    
    public func remove(at codingPath: [CodingKey]) throws -> Meta? {
        
        let converted = concatCodingPath(codingPath)
        
        guard !locks.contains(converted) else {
            throw CodingStorageError.pathIsLocked
        }
        
        guard let value = heap.removeValue(forKey: converted) else {
            throw CodingStorageError.noMetaStoredAtThisCodingPath
        }
        
        return value is PlaceholderMeta ? nil : value
        
    }
    
    public func lock(codingPath: [CodingKey]) throws {
        
        let converted = concatCodingPath(codingPath)
        
        guard heap[converted] != nil else {
            throw CodingStorageError.noMetaStoredAtThisCodingPath
        }
        
        locks.insert(converted)
        
    }
    
    public func unlock(codingPath: [CodingKey]) {
        
        locks.remove( concatCodingPath(codingPath) )
        
    }
    
    // no need to create a new storage in this implementation
    public func fork(at codingPath: [CodingKey]) -> CodingStorage {
        
        return self
    }
    
}
