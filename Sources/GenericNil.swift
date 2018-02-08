//
//  GenericNil.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/// Represents a nil value
public struct GenericNil: DirectlyCodable {
    
    public static let instance: GenericNil = GenericNil()
    
    private init() {  }
    
}
