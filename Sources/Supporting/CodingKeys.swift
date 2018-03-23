//
//  CodingKeys.swift
//  meta-serialization
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
    
    /// will return the index as string value
    public var stringValue: String {
        return "\(intValue!)"
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
    
    /// used by the superEncoder() methods in MetaKeyed(Encoding|Decoding)Containers
    case `super` = "super"
    
}

/// A CodingKey with a special meaning. This kind of CodingKey is used
public struct NonRegualarCodingKey: CodingKey, ExpressibleByStringLiteral, Equatable {
    
    // MARK: - string literal expressible
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral string: String) {
        self.stringValue = string
    }
    
    // MARK: - Equatable
    
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
