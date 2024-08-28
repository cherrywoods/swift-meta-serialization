//
//  Encoder.swift
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
@testable import MetaSerialization

class Example3Encoder: MetaEncoder {
    
    let firstCodingPathLength: Int
    
    init(at codingPath: [CodingKey] = [],
                  with userInfo: [CodingUserInfoKey : Any] = [:]) {
        
        self.firstCodingPathLength = codingPath.count
        super.init(at: codingPath, with: userInfo, metaSupplier: Example3Translator())
        
    }
    
    // override to allow only first level containers
    
    override func encodingContainer<Key>(keyedBy keyType: Key.Type, referencing reference: Reference, at codingPath: [CodingKey]) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        
        guard codingPath.count - firstCodingPathLength == 0 else {
            return ErrorContainer.newContainer(keyedBy: keyType,
                                               with: Example3.Errors.onlyTopLevelContainersAllowed(at: codingPath),
                                               codingPath: codingPath)
        }
        
        return super.encodingContainer(keyedBy: keyType, referencing: reference, at: codingPath)
        
    }
    
    override func unkeyedEncodingContainer(referencing reference: Reference, at codingPath: [CodingKey]) -> UnkeyedEncodingContainer {
        
        guard codingPath.count - firstCodingPathLength == 0 else {
            return ErrorContainer(error: Example3.Errors.onlyTopLevelContainersAllowed(at: codingPath), codingPath: codingPath)
        }
        
        return super.unkeyedEncodingContainer(referencing: reference, at: codingPath)
        
    }
    
    override func encoder(referencing reference: Reference, at codingPath: [CodingKey]) -> Encoder {
        
        guard codingPath.count - firstCodingPathLength == 0 else {
            return ErrorContainer(error: Example3.Errors.onlyTopLevelContainersAllowed(at: codingPath), codingPath: codingPath)
        }
        
        return super.encoder(referencing: reference, at: codingPath)
        
    }
    
    
}
