//
//  StringWrapperStandardTypes.swift
//  meta-serialization
//
//  Created by cherrywoods on 26.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/*
 NOTE: it seems to me, as if Float80 would not rely on single value containers to be encoded or decoded
       therefore there's actually no real need to provide this type
*/

// MARK: Float80

public struct Float80WrappedToStringMeta: WrappingMeta {
    public typealias WrappedType = Float80
    public typealias WrappingType = String
    public var wrappedValue: Float80?
}
