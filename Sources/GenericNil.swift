//
//  GenericNil.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/// Represents a nil value
public struct GenericNil: DirectlyCodable {
    
    public static let instance: GenericNil = GenericNil()
    
    private init() {  }
    
}
