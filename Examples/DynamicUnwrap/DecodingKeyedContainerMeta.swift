//
//  DecodingKeyedContainerMeta.swift
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
@testable import MetaSerialization

struct Example2DecodingKeyedContainerMeta: DecodingKeyedContainerMeta {
    
    let values: Dictionary<String, Example2Meta>
    
    /// Returns a new decoding container meta, if array can be seen a keyed container.
    init?(array: [Example2Meta]) {
        
        guard !array.isEmpty else {
            // if array is empty, it can always be a keyed container
            self.values = [:]
            return
        }
        
        guard array.count % 2 == 0 else {
            // if the number of elements isn't just, it can't be an array of key value pairs.
            return nil
        }
        
        var keys: [String] = []
        var values: [Example2Meta] = []
        for index in 0..<array.count {
            
            if index % 2 == 0 {
                
                // just elements are seen as keys
                
                guard let key = array[index] as? String else {
                    // keys need to be Strings (and not Arrays of Strings)
                    return nil
                }
                keys.append( key )
                
            } else {
                // odds are values
                values.append( array[index] )
            }
            
        }
        
        // check that there are no duplicate keys:
        // sort keys, so we don't need to compare all keys to all keys
        keys = keys.sorted()
        // now we just need to go through all keys and compare with the key before
        var lastKey = keys.first! // since array isn't empty, there is at least one key
        for key in keys.suffix( keys.count-1 /*All keys, except the first one*/ ) {
            
            guard key != lastKey else {
                // if keys aren't unique, array can't be seen as a keyed container
                return nil
            }
            
            lastKey = key
            
        }
        
        self.values = Dictionary(uniqueKeysWithValues: zip(keys, values))
        
    }
    
    // MARK: keyed container furctionality
    
    var allKeys: [MetaCodingKey] {
        return values.keys.map { MetaCodingKey(stringValue: $0) }
    }
    
    func contains(key: MetaCodingKey) -> Bool {
        return values[key.stringValue] != nil
    }
    
    func getValue(for key: MetaCodingKey) -> Meta? {
        return values[key.stringValue]
    }
    
}
