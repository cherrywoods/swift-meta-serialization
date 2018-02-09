//
//  CodingStack.swift
//  meta-serialization
//
//  Created by cherrywoods on 18.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/// The possible statuses of a CodingStack.
public enum CodingStackStatus {
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

/// An Error that may occur when working with a CodingStack
enum CodingStackError: Error {
    /// thrown if the stack is in the wrong status
    case statusMismatch(expected: CodingStackStatus, current: CodingStackStatus)
    case emptyStack
}

public protocol CodingStack {
    
    /**
     The coding path of the meta currently on top of the stack.
     The coding path consist of all coding keys added up to the encoding of the currently encoding entity.
     */
    var codingPath: [CodingKey] { get }
    
    // MARK: - stack validation
    
    /// the current status of the CodingStack
    var status: CodingStackStatus { get }
    
    /// indicates whether push(meta: ) can curretly be called without throwing an error.
    var mayPushNewMeta: Bool { get }
    /// indicates whether pop() can curretly be called without throwing an error.
    var mayPopMeta: Bool { get }
    /// indicates whether append(codingKey: ) can curretly be called without throwing an error.
    var mayAppendNewCodingKey: Bool { get }
    /// indicates whether removeLastCodingKey() can curretly be called without throwing an error.
    var mayRemoveLastCodingKey: Bool { get }
    
    // MARK: - init
    
    /**
     Inits a new CodingStack at the given codingPath.
     By default, `at` should be an empty array and `with` should be .pathMissesMeta
     */
    init(at codingPath: [CodingKey], with status: CodingStackStatus )
    
    // MARK: - stack methods
    
    // MARK: metas
    
    /// whether the meta stack is empty
    var isEmpty: Bool { get }
    /// the number of metas added to this stack
    var count: Int { get }
    
    /// the last element of the stack
    var last: Meta? { get }
    
    /// the first element of the stack
    var first: Meta? { get }
    
    /// the last (valid) index of the (meta) stack
    var lastIndex: Int { get }
    
    subscript (index: Int) -> Meta { get set }
    
    /**
     push a new meta on top of the stack
     
     - Throws: StackError.statusMismatch if status != .pathMissesMeta
     */
    func push(meta: Meta) throws
    
    /**
     pops a meta from the top of the stack
     
     - Throws:
     - StackError.emptyStack if the meta stack is empty
     - StackError.statusMismatch: if status != .pathMissesMeta
     */
    func pop() throws -> Meta
    
    // MARK: coding keys
    
    /**
     appends a new CodingKey to the codingPath
     - Throws: StackError.statusMismatch if status != .pathFilled
     */
    func append(codingKey key: CodingKey) throws
    
    /**
     removes the last CodingKey from the codingPath
     - Throws: StackError.statusMismatch if status != .pathMissesMeta
     */
    func removeLastCodingKey() throws
    
}
