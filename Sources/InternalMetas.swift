//
//  InternalMetas.swift
//  meta-serialization-iOS
//
//  Created by cherrywoods on 02.11.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/*
 This meta is used during encoding single values using SingleValueContainers as placeholder on the CodingStack
 it may never reach Translator or any other type outside the framwork in any form!!!
 */
internal struct PlaceholderMeta: Meta {
    
    func set(value: Any) {
        // do nothing
    }
    
    func get() -> Any? {
        return NSNull()
    }
    
}
