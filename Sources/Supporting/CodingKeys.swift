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
public enum SpecialCodingKey: StandardCodingKey {
    
    /// used by the super(Encoder|Decoder)() methods in MetaKeyed(Encoding|Decoding)Containers
    case `super` = "super,0" // documentation says, that the int value of a super key is 0
    
}

/**
 A CodingKey type initalizable with any string or int value.
 
 This coding key type is exapressible by a string literal in the form `<stringValue>,<intValue>`
 where `<stringValue>` it the keys string value and `<intValue>` is the keys int value.
 You may ommit `,<intValue>`, in which case the coding key will have no int value.
 You may also ommit `<stringValue>` in which case coding keys stringValue will be "\(intValue)".
 
 Therefor valid string literals for a coding key are:
  * `<stringValue>,<intValue>`
  * `<stringValue>`
  * `,<intValue>`
 If the string literal includes more than one `,` sequence, only the string after the last occurence will be interpreted as int value.
 
 If <intValue> isn't convertible to Int, the coding key will be initalizes with the while string literal as stringValue and without an intValue.
 */
public struct StandardCodingKey: CodingKey, ExpressibleByStringLiteral, Equatable {
    
    // MARK: - CodingKey
    
    public var stringValue: String
    public var intValue: Int?
    
    public init(stringValue: String, intValue: Int) {
        self.stringValue = stringValue
        self.intValue = intValue
    }
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
 
    /// Sets stringValue to "\(intValue)"
    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)", intValue: intValue)
    }
    
    // MARK: - string literal expressible
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral string: String) {
        
        let parts = string.split(separator: ",")
        guard let last = parts.last, let intValue = Int(last) else {
            self.stringValue = string
            return
        }
        
        self.intValue = intValue
        
        if parts.count == 1 {
            
            // this means no string value, literal is in form ",<intValue>"
            self.stringValue = "\(intValue)"
            
        } else {
            
            // set string value to the whole string before the last komma.
            self.stringValue = String( string.prefix(string.count - last.count /* do not include the ",": */- 1) )
            
        }
        
    }
    
    // MARK: - Equatable
    
    public static func ==(lhs: StandardCodingKey, rhs: StandardCodingKey) -> Bool {
        return lhs.stringValue == rhs.stringValue && lhs.intValue == rhs.intValue
    }
    
}
