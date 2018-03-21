//
//  LinearCodingStack.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

/**
 A `CodingStorage` that stores it's metas on a stack.
 
 This coding stack requires a strictly sequential (de|en)coding process.
 */
open class LinearCodingStack: CodingStorage {
    
    /**
     Stores the metas.
     */
    private var stack: [Meta]
    
    // MARK: working with coding paths
    
    /// simply projects paths to their length
    private func convertToIndex(codingPath: [CodingKey]) -> Int {
        
        return codingPath.count - tolerationDepth
        
    }
    
    /// coding paths do not need to be contained in the stack up to this depth. Beyond it they need to.
    private let tolerationDepth: Int
    
    // MARK: initalization
    
    /// Inits a new empty LinearCodingStack
    public init(root: [CodingKey] = []) {
        
        // unconditionally store a placeholder at the root path.
        self.stack = [ PlaceholderMeta.instance ]
        self.tolerationDepth = root.count
        
    }
    
    // MARK: CodingStorage implementation
    
    open subscript(codingPath: [CodingKey]) -> Meta {
        
        get {
            
            return stack[ convertToIndex(codingPath: codingPath) ]
            
        }
        
        set {
            
            let index = convertToIndex(codingPath: codingPath)
            
            if index < stack.endIndex {
                
                stack[ convertToIndex(codingPath: codingPath) ] = newValue
                
            } else if index == stack.endIndex {
                
                stack.append( newValue )
                
            } else {
                
                preconditionFailure("Storage not filled up to requested path.")
                
            }
            
        }
        
    }
    
    open func storesMeta(at codingPath: [CodingKey]) -> Bool {
        
        let index = convertToIndex(codingPath: codingPath)
        
        if index < stack.endIndex {
            
            return !(stack[index] is PlaceholderMeta)
            
        } else {
            
            // if index is bigger than the last used index
            // there is no value stored
            return false
            
        }
        
    }
    
    open func store(meta: Meta, at codingPath: [CodingKey]) throws {
        
        let index = convertToIndex(codingPath: codingPath)
        
        if stack.last is PlaceholderMeta {
            
            // index needs to be the last used index
            guard index >= stack.endIndex-1 else {
                throw CodingStorageError(reason: .alreadyStoringValueAtThisCodingPath, path: codingPath)
            }
            
            guard index == stack.endIndex-1 else {
                throw CodingStorageError(reason: .pathNotFilled, path: codingPath)
            }
            
            stack[index] = meta
            
        } else {
            
            // index needs to be the first past the end index
            guard index >= stack.endIndex else {
                throw CodingStorageError(reason: .alreadyStoringValueAtThisCodingPath, path: codingPath)
            }
            
            guard index == stack.endIndex else {
                throw CodingStorageError(reason: .pathNotFilled, path: codingPath)
            }
            
            stack.append( meta )
            
        }
        
    }
    
    open func storePlaceholder(at codingPath: [CodingKey]) throws {
        
        try store(meta: PlaceholderMeta.instance, at: codingPath)
        
    }
    
    open func remove(at codingPath: [CodingKey]) throws -> Meta? {
        
        let index = convertToIndex(codingPath: codingPath)
        
        // index needs to be the last used index
        guard index == stack.endIndex-1 else {
            throw CodingStorageError(reason: .noMetaStoredAtThisCodingPath, path: codingPath)
        }
        
        guard stack.last != nil else {
            throw CodingStorageError(reason: .noMetaStoredAtThisCodingPath, path: codingPath)
        }
        
        let value = stack.removeLast()
        // convert placeholders to nils
        return value is PlaceholderMeta ? nil : value
        
    }
    
    open func fork(at codingPath: [CodingKey]) -> CodingStorage {
        
        return LinearCodingStack(root: codingPath)
        
    }
    
}

