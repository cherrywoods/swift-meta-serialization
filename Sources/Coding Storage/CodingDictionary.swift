//
//  CodingTable.swift
//  MetaSerialization
//
//  Copyright 2018 cherrywoods
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

// TODO: add doc whether supports parallel encoding

/**
 A `CodingStorage` that stores it's metas in a dictionary.
 It keeps no ordering of the metas contained in it.
 */
open class CodingDictionary: CodingStorage {
    
    /// stores metas for concatenations of string values of coding keys
    private var heap: Dictionary<String, Meta>
    
    // MARK: utilities
    
    /// converts a coding path to the internally used format
    private static func concatCodingPath(_ path: Array<CodingKey>) -> String {
        
        return concatCodingPath( path[0..<path.endIndex] )
        
    }
    
    private static func concatCodingPath(_ path: ArraySlice<CodingKey>) -> String {
        
        var result = ""
        for key in path {
            result += convert(codingKey: key)
        }
        return result
        
    }
    
    private static func convert(codingKey key: CodingKey) -> String {
        
        return "/\(key.stringValue)"
        
    }
    
    // MARK: initalization
    
    /// Initalizes a new empty CodingHeap.
    public required init(root: [CodingKey] = []) {
        
        // unconditionally store a placeholder at the root path
        // so new metas can be stored
        heap = [ CodingDictionary.concatCodingPath(root) : PlaceholderMeta.instance ]
        
    }
    
    // MARK: CodingStorage implementation
    
    open subscript(path: [CodingKey]) -> Meta {
        
        get {
            
            return heap[ CodingDictionary.concatCodingPath(path) ]!
            
        }
        
        set {
            
            heap[ CodingDictionary.concatCodingPath(path) ] = newValue
            
        }
        
    }
    
    open func storesMeta(at codingPath: [CodingKey]) -> Bool {
        
        let converted = CodingDictionary.concatCodingPath(codingPath)
        let meta = heap[converted]
        // if meta is nil, there is no meta stored
        return meta != nil && !(meta is PlaceholderMeta)
        
    }
    
    open func store(meta: Meta, at codingPath: [CodingKey]) throws {
        
        let lastPath = codingPath.endIndex >= 1 ?  CodingDictionary.concatCodingPath( codingPath[0..<codingPath.endIndex-1] ) : ""
        let convertedPath = lastPath + CodingDictionary.convert(codingKey: codingPath.last!)
        
        if let old = heap[convertedPath] {
            
            // if there is already somnething stored at codingPath,
            // don't ask whether the key before it is also contained
            // (if we did, nothing could ever be encoded)
            
            // guard that the previously stored value is a placeholder
            guard old is PlaceholderMeta else {
                throw CodingStorageError(reason: .alreadyStoringValueAtThisCodingPath, path: codingPath)
            }
            
        } else {
            
            // check containance of previous path
            // if there was no value stored at the current path before
            guard heap[lastPath] != nil else {
                throw CodingStorageError(reason: .pathNotFilled, path: codingPath)
            }
            
        }
        
        // store meta if no error was thrown above
        heap[convertedPath] = meta
        
    }
    
    open func storePlaceholder(at codingPath: [CodingKey]) throws {
        
        try store(meta: PlaceholderMeta.instance, at: codingPath)
        
    }
    
    open func remove(at codingPath: [CodingKey]) throws -> Meta? {
        
        let converted = CodingDictionary.concatCodingPath(codingPath)
        
        guard let value = heap.removeValue(forKey: converted) else {
            throw CodingStorageError(reason: .noMetaStoredAtThisCodingPath, path: codingPath)
        }
        
        return value is PlaceholderMeta ? nil : value
        
    }
    
    open func fork(at codingPath: [CodingKey]) -> CodingStorage {
        
        // no need to create a new storage. This storage allows "branching"
        return self
        
    }
    
}
