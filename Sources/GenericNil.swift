//
//  GenericNil.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/// Represents a nil value
public struct GenericNil: Codable {
    
    public static let instance: GenericNil = GenericNil()
    
    private init() {  }
    
}

/**
 This struct is the equivalent to GenericNil on the decoding side
 
 You will be asked to decode this type to check, whether a value is nil.
 You will then return an instance of this type, correspoding to wheather you found a value or not/found a null value.
 */
public struct ValuePresenceIndicator: Codable {
    
    public let isNil: Bool
    
    public init(isNil: Bool) {
        self.isNil = isNil
    }
    
    /// shortcut for init(isNil: value == nil)
    public init(value: Any?) {
        self.init(isNil: value == nil)
    }
    
}
