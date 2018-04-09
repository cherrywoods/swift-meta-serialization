//
//  Container.swift
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

enum Example1Container {
    
    case `nil`
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case array([Example1Container])
    case dictionary([String:Example1Container])
    
}

extension Example1Container: Hashable {
    
    var hashValue: Int {
        switch self {
        case .nil:
            return 42
        case .bool(let val):
            return val.hashValue
        case .string(let val):
            return val.hashValue
        case .int(let val):
            return val.hashValue
        case .double(let val):
            return val.hashValue
        case .array(let val):
            return val.count.hashValue
        case .dictionary(let val):
            return val.count.hashValue
        }
    }
    
    static func ==(lhs: Example1Container, rhs: Example1Container) -> Bool {
        
        switch (lhs, rhs) {
        case (.nil, .nil):
            return true
        case (.bool(let lhv), .bool(let rhv)):
            return lhv == rhv
        case (.string(let lhv), .string(let rhv)):
            return lhv == rhv
        case (.int(let lhv), .int(let rhv)):
            return lhv == rhv
        case (.double(let lhv), .double(let rhv)):
            return lhv == rhv
        case (.array(let lhv), .array(let rhv)):
            return lhv == rhv
        case (.dictionary(let lhv), .dictionary(let rhv)):
            return lhv == rhv
        default:
            return false
        }
        
    }
    
}

extension Example1Container: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .nil:
            return "nil"
        case .bool(let val):
            return val.description
        case .string(let val):
            return val.description
        case .int(let val):
            return val.description
        case .double(let val):
            return val.description
        case .array(let val):
            return val.description
        case .dictionary(let val):
            return val.description
        }
    }
    
}
