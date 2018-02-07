//
//  StrictCodingStack.swift
//  MetaSerialization
//
//  Created by cherrywoods on 06.02.18.
//

import Foundation


/**
 StrictCodingStack is the default implementation of CodingStack of MetaSerialization.
 
 StrictCodingStack allows exactly one meta per key and requires that the workflow of append-push-(nest same workflow)-pop-removeLastCodingKey is always followed.
 */
open class StrictCodingStack: CodingStack {
    
    /**
     The coding path of the meta currently on top of the stack.
     The coding path consist of all coding keys added up to the encoding of the currently encoding entity.
     */
    private(set) public var codingPath: [CodingKey]
    
    // the nth element of the stack refers to the n-1th element of codingPath
    private var metaStack: [Meta]
    
    // MARK: - stack validation
    
    /// the current status of the CodingStack
    private(set) public var status: CodingStackStatus
    
    /// indicates whether push(meta: ) can curretly be called without throwing an error.
    public var mayPushNewMeta: Bool {
        
        // to support the way single value container and MetaEncoder handle entities,
        // that request single value containers,
        // it also needs to be allowed to push to this stack, if the last element is a PlacholderMeta
        return status == .pathMissesMeta || isLastMetaPlaceholder
        
    }
    private var isLastMetaPlaceholder: Bool {
        return ( self.last != nil && (self.last! is PlaceholderMeta) )
    }
    /// indicates whether pop() can curretly be called without throwing an error.
    public var mayPopMeta: Bool {
        return status == .pathFilled
    }
    /// indicates whether append(codingKey: ) can curretly be called without throwing an error.
    public var mayAppendNewCodingKey: Bool {
        return status == .pathFilled
    }
    /// indicates whether removeLastCodingKey() can curretly be called without throwing an error.
    public var mayRemoveLastCodingKey: Bool {
        return status == .pathMissesMeta
    }
    
    // MARK: - init
    
    /**
     inits a new CodingStack at the given codingPath.
     By default, `at` is an empty array and `with` is .pathMissesMeta
     */
    public required init(at codingPath: [CodingKey] = [], with status: CodingStackStatus = .pathMissesMeta ) {
        
        self.codingPath = codingPath
        self.metaStack = []
        
        self.status = status
        
    }
    
    // MARK: - stack methods
    
    // MARK: metas
    
    /// whether the meta stack is empty
    public var isEmpty: Bool {
        return metaStack.isEmpty
    }
    /// the number of metas added to this stack
    public var count: Int {
        return metaStack.count
    }
    
    /// the last element of the stack
    public var last: Meta? {
        return metaStack.last
    }
    
    /// the first element of the stack
    public var first: Meta? {
        return metaStack.first
    }
    
    /// the lastIndex of the (meta) stack
    public var lastIndex: Int {
        return metaStack.endIndex-1 // endindex is "behind the end" position, not the last set index
    }
    
    public subscript (index: Int) -> Meta {
        get {
            return metaStack[index]
        }
        set {
            
            // this may happen,
            // during encode(_) in a single value container
            // (endIndex is the "past the end position")
            if index == metaStack.endIndex {
                
                // just do this if index is exactly the index past the end!
                // appending would produce chaos on the stack,
                // if index is larger than endIndex.
                // Additionally I think that this should not happen.
                
                // need to push to preserve the stack status etc.
                try! push(meta: newValue)
                
            } else {
                
                metaStack[index] = newValue
                
            }
            
        }
    }
    
    /**
     push a new meta on top of the stack
     
     - Throws: StackError.statusMismatch if status != .pathMissesMeta
     */
    public func push(meta: Meta) throws {
        
        // check wether we are awaiting a meta to be pushed
        guard self.mayPushNewMeta else {
            throw CodingStackError.statusMismatch(expected: .pathMissesMeta, current: self.status)
        }
        
        // push replaces PlaceholderMetas itself
        if isLastMetaPlaceholder {
            
            // remove the last meta
            metaStack.removeLast()
            
        }
        
        // push meta
        metaStack.append(meta)
        
        self.status = .pathFilled
        
    }
    
    /**
     pops a meta from the top of the stack
     
     - Throws:
     - StackError.emptyStack if the meta stack is empty
     - StackError.statusMismatch: if status != .pathMissesMeta
     */
    public func pop() throws -> Meta {
        
        // check whether the meta stack is not empty
        guard !self.isEmpty else {
            throw CodingStackError.emptyStack
        }
        
        // check whether status is .pathFilled
        guard self.status == .pathFilled else {
            throw CodingStackError.statusMismatch(expected: .pathFilled, current: self.status)
        }
        
        self.status = .pathMissesMeta
        
        return metaStack.removeLast()
        
    }
    
    // MARK: coding keys
    
    /**
     appends a new CodingKey to the codingPath
     - Throws: StackError.statusMismatch if status != .pathFilled
     */
    public func append(codingKey key: CodingKey) throws {
        
        guard self.status == .pathFilled else {
            throw CodingStackError.statusMismatch(expected: .pathFilled, current: self.status)
        }
        
        codingPath.append(key)
        
        self.status = .pathMissesMeta
        
    }
    
    /**
     removes the last CodingKey from the codingPath
     - Throws: StackError.statusMismatch if status != .pathMissesMeta
     */
    public func removeLastCodingKey() throws {
        
        guard self.status == .pathMissesMeta else {
            throw CodingStackError.statusMismatch(expected: .pathMissesMeta, current: self.status)
        }
        
        codingPath.removeLast()
        
        self.status = .pathFilled
        
    }
    
}
