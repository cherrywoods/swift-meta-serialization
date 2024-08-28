//
//  ReferencingStorage.swift
//  MetaSerialization
//
//  Copyright 2018-2024 cherrywoods
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/**
 A CodingStorage that writes the Meta on it's base path back to another storage.
 
 This storage will write back the Meta stored to the base path to reference.
 */
open class ReferencingCodingStorage: CodingStorage {
    
    // MARK: properties
    
    open var reference: Reference
    public let basePath: [CodingKey]
    open var delegate: CodingStorage
    
    // MARK: init
    
    /**
     Creates a new ReferencingCodingStorage for a base path that writes back to the given reference and uses storage as the underlying delegate.
     
     The storage needs to be able to store a Meta at basePath.
     */
    public init(referencing reference: Reference, delegatingTo storage: CodingStorage, at basePath: [CodingKey] ) {
        
        self.reference = reference
        self.basePath = basePath
        self.delegate = storage
        
        try! delegate.storePlaceholder(at: basePath)
        
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
        
        precondition(codingPath != basePath, "Removing meta at base path of referencing storage isn't allowed.")        
        return try delegate.remove(at: codingPath)
        
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
 Provide == operator for coding paths
 */
fileprivate extension Array where Element == CodingKey {
    
    static func ==(lhs: [CodingKey], rhs: [CodingKey]) -> Bool {
        
        guard lhs.count == rhs.count else {
            return false
        }
        
        var lhsKey: CodingKey, rhsKey: CodingKey
        
        for index in (0..<lhs.count).reversed() {
            
            lhsKey = lhs[ lhs.startIndex.advanced(by: index) ]
            rhsKey = rhs[ rhs.startIndex.advanced(by: index) ]
            
            guard lhsKey.stringValue == rhsKey.stringValue else {
                return false
            }
            
        }
        
        return true
        
    }
    
    static func !=(lhs: [CodingKey], rhs: [CodingKey]) -> Bool {
        return !(lhs == rhs)
    }
    
}
