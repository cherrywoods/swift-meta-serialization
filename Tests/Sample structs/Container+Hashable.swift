//
//  Container+Hashable.swift
//  MetaSerializationTests macOS
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

extension Container: Hashable {
    
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
    
    static func ==(lhs: Container, rhs: Container) -> Bool {
        
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
