//
//  GenericNil.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

/// Represents a nil value
public struct GenericNil: DirectlyCodable {
    
    public static let instance: GenericNil = GenericNil()
    
    private init() {  }
    
}
