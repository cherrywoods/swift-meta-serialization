//
//  LinearCodingStack.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

// TODO: doc
open class LinearCodingStack: CodingStorage {
    
    /**
     stores the metas and whether they are locked or not
     metas are unlocked by default
     */
    private var stack: [(Meta, Bool)]
    
    /// simply projects paths to their length
    private func convertToIndex(codingPath: [CodingKey]) -> Int {
        
        return codingPath.count
        
    }
    
    public required init() {
        
        stack = Array<(Meta, Bool)>()
        
    }
    
    public var hasMultipleMetasInStorage: Bool {
        
        return stack.count == 1
        
    }
    
    public subscript(codingPath: [CodingKey]) -> Meta {
        
        get {
            
            return stack[ convertToIndex(codingPath: codingPath) ].0
            
        }
        
        set {
            
            stack[ convertToIndex(codingPath: codingPath) ] = (newValue, false)
            
        }
        
    }
    
    public func isMetaStored(at codingPath: [CodingKey]) -> Bool {
        
        let index = convertToIndex(codingPath: codingPath)
        
        if index < stack.endIndex {
            
            return !(stack[index].0 is PlaceholderMeta)
            
        } else {
            
            // if index is bigger than the last used index
            // there is no value stored
            return false
            
        }
        
    }
    
    public func store(meta: Meta, at codingPath: [CodingKey]) throws {
        
        let index = convertToIndex(codingPath: codingPath)
        
        if stack.last?.0 is PlaceholderMeta {
            
            // index needs to be the last used index
            guard index >= stack.endIndex-1 else {
                throw CodingStorageError.alreadyStoringValueAtThisCodingPath
            }
            
            guard index == stack.endIndex-1 else {
                throw CodingStorageError.pathNotFilled
            }
            
            stack[index] = (meta, false)
            
        } else {
            
            // index needs to be the first past the end index
            guard index >= stack.endIndex else {
                throw CodingStorageError.alreadyStoringValueAtThisCodingPath
            }
            
            guard index == stack.endIndex else {
                throw CodingStorageError.pathNotFilled
            }
            
            stack.append( (meta, false) )
            
        }
        
    }
    
    public func storePlaceholder(at codingPath: [CodingKey]) throws {
        
        try store(meta: PlaceholderMeta.instance, at: codingPath)
        
    }
    
    public func remove(at codingPath: [CodingKey]) throws -> Meta? {
        
        let index = convertToIndex(codingPath: codingPath)
        
        // index needs to be the last used index
        guard index == stack.endIndex-1 else {
            throw CodingStorageError.noMetaStoredAtThisCodingPath
        }
        
        guard let last = stack.last else {
            throw CodingStorageError.noMetaStoredAtThisCodingPath
        }
        
        // check that the meta isn't locked
        guard !last.1 else {
            throw CodingStorageError.pathIsLocked
        }
        
        let value = stack.removeLast().0
        // convert placeholders to nils
        return value is PlaceholderMeta ? nil : value
        
    }
    
    public func lock(codingPath: [CodingKey]) throws {
        
        let index = convertToIndex(codingPath: codingPath)
        
        guard index < stack.endIndex else {
            throw CodingStorageError.noMetaStoredAtThisCodingPath
        }
        
        stack[index].1 = true
        
    }
    
    public func unlock(codingPath: [CodingKey]) {
        
        let index = convertToIndex(codingPath: codingPath)
        
        guard index < stack.endIndex else {
            // do nothing if index is out of range
            return
        }
        
        stack[index].1 = false
        
    }
    
    public func fork() -> CodingStorage {
        
        // return a new coding stack
        return LinearCodingStack()
        
    }
    
}

