//
//  CodingStack.swift
//  meta-serialization
//
//  Created by cherrywoods on 18.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 CodingStack is a collection of metas and codingKeys with special adding and removing rules.
 
 It is a stack in that sence that new elements may only be added on top and only be removed from top of the stack.
 However elements at a specific index can be read, but not removed added or written.
 
 Furthermore the stack checks that every codingKey has also an associated meta, before a new CodingKey can be added (prevents entities encoding or decoding from requesting no container) and checks, that metas are only added if a CodingKey was added for them befor (prevents entities encoding or decoding from requesting more than one container).
 
 Howeverit does not guarantee, that there is a meta for every CodingKey.
 */
open class CodingStack {
    
    /**
     The coding path of the meta currently on top of the stack.
     The coding path consist of all coding keys added up to the encoding of the currently encoding entity.
     */
    private(set) public var codingPath: [CodingKey]
    
    // the nth element of the stack refers to the n-1th element of codingPath
    private var metaStack: [Meta]
    
    // MARK: - stack validation
    
    /// the current status of the CodingStack
    private(set) public var status: Status
    
    /// indicates whether push(meta: ) can curretly be called without throwing an error.
    public var mayPushNewMeta: Bool {
        // to support the way single value container and MetaEncoder handle entities,
        // that request single value containers,
        // it also needs to be allowed to push to this stack, if the last element is a PlacholderMeta
        return status == .pathMissesMeta
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
    
    /// The possible statuses of a CodingStack.
    public enum Status {
        /**
         First status of a new CodingStack.
         Expresses that a new meta needs to be added or a codingKey needs to be removed to proceed.
        */
        case pathMissesMeta
        /**
         If a CodingStack has this status, it currently contains at least one meta and waits for a new coding key, so another meta may be added.
         
         Expresses, that a coding key may be added, or a meta removed.
         This status expresses some validity of the stack, respectively that it is not waiting for a meta to be pushed.
         */
        case pathFilled
    }
    
    /// Enumerates all possible Operations that can be performed on a CodingStack.
    public enum Operation {
        case initalization
        case pushed
        case poped
        case appended
        case removedLast
    }
    
    /// An Error that may occur when working with a CodingStack
    public enum StackError: Error {
        /// thrown if the stack is in the wrong status
        case statusMismatch(expected: Status, current: Status)
        case emptyStack
    }
    
    // MARK: - init
    
    /**
     inits a new CodingStack at the given codingPath.
     By default, `at` is an empty array and `with` is .pathMissesMeta
     */
    public init(at codingPath: [CodingKey] = [], with status: Status = .pathMissesMeta ) {
        
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
            metaStack[index] = newValue
        }
    }
    
    /**
     push a new meta on top of the stack
    
     - Throws: StackError.statusMismatch if status != .pathMissesMeta
     */
    public func push(meta: Meta) throws {
        
        // check wether we are awaiting a meta to be pushed
        guard self.mayPushNewMeta else {
            throw StackError.statusMismatch(expected: .pathMissesMeta, current: self.status)
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
            throw StackError.emptyStack
        }
        
        // check whether status is .pathFilled
        guard self.status == .pathFilled else {
            throw StackError.statusMismatch(expected: .pathFilled, current: self.status)
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
            throw StackError.statusMismatch(expected: .pathFilled, current: self.status)
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
            throw StackError.statusMismatch(expected: .pathMissesMeta, current: self.status)
        }
        
        codingPath.removeLast()
        
        self.status = .pathFilled
        
    }
    
}
