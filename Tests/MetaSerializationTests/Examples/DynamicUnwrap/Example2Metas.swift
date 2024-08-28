//
//  BasicMetas.swift
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

indirect enum Example2Meta: Meta {
    
    case string(String)
    case array([Example2Meta])
    
}

extension Example2Meta: Equatable {
    
    static func ==(lhs: Example2Meta, rhs: Example2Meta) -> Bool {
        
        switch (lhs, rhs) {
        case (.string(let lhValue), .string(let rhValue)):
            return lhValue == rhValue
        case (.array(let lhValue), .array(let rhValue)):
            return lhValue == rhValue
        default:
            return false
        }
        
    }
    
}
