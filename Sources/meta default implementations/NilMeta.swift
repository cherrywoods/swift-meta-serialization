//
//  NilMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 18.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 A Meta for representing nil
 get will return NSNull(), set will stay lazy and do nothing
 */
public struct NilMeta: NilMetaProtocol {
    
    public static let `nil`: NilMeta = NilMeta()
    
    /// does nothing
    public func set(value: Any) {
        // do nothing
    }
    
    /// will allways return NSNull()
    public func get() -> Any? {
        return NSNull()
    }
    
}
