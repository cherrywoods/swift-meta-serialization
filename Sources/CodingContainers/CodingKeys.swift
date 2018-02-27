//
//  CodingKeys.swift
//  meta-serialization
//
//  Created by cherrywoods on 17.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/// A special coding key represents an index in an unkeyed container
public struct IndexCodingKey: CodingKey {
    
    /// the index
    public let intValue: Int?
    
    /**
     construct a new IndexCodingKey by passing an index.
     This initalizer will fail, if intValue is not a valid index, i.e. is smaller than 0
     - Paramter intValue: the index. Must be larger or equal than 0, otherwise the initalizer will fail
     */
    public init?(intValue: Int) {
        
        guard intValue >= 0 else {
            return nil
        }
        
        self.intValue = intValue
    }
    
    // MARK: casting to and from strings
    
    /// will return "Index: " followed by the index
    public var stringValue: String {
        return "Index: \(intValue!)"
    }
    
    /**
     constructs a new IndexCodingKey from the given sting, that needs to be base 10 encoded intenger representation.
     this initalizer used Int(_ description: String) to convert stringValue
     see Int(_ description: String) for mere details about which strings will succeed
     */
    public init?(stringValue string: String) {
        
        guard let index = Int(string) else {
            return nil
        }
        
        self.init(intValue: index)
        
    }
    
}

/// An enumeration of all special coding keys meta-serialization will use
public enum SpecialCodingKey: NonRegualarCodingKey {
    
    /// used by the superEncoder() methods in MetaKeyed- Encoding- and Decoding- containers
    case `super` = "super"
    
    /// used by SingleValueEncodingContainer to decode containers that were requested as single value containers but are none
    case singleValueContainer = "codingThroughSingleValueContainer"
    
}

/// A CodingKey with a special meaning. This kind of CodingKey is used
public struct NonRegualarCodingKey: CodingKey, ExpressibleByStringLiteral, Equatable {
    
    // MARK: - string literal expressible
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral string: String) {
        self.stringValue = string
    }
    
    // MARK: - equatable
    
    public static func ==(lhs: NonRegualarCodingKey, rhs: NonRegualarCodingKey) -> Bool {
        return lhs.stringValue == rhs.stringValue
    }
    
    // MARK: - CodingKey
    
    public var stringValue: String
    
    public init?(stringValue: String) {
        self.init(stringLiteral: stringValue)
    }
    
    public var intValue: Int? {
        
        switch stringValue {
            // special cases
        case SpecialCodingKey.super.rawValue.stringValue: // or in other words "super"
            
            // refering to the swift standard library documentation of KeyedEncodingContainer, this is the int value for the super CodingKey
            return 0
            
        default:
            
            if let int = Int(stringValue) {
                return int
            } else {
                return nil
            }
            
        }
        
    }
    
    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
    }
    
}
