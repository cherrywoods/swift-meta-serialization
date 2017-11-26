//
//  NilMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 18.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
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
