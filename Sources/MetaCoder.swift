//
//  MetaCoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 19.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/// common interface for encoder and decoder
public protocol MetaCoder {
    
    var codingPath: [CodingKey] { get }
    
    var stack: CodingStack { get set }
    var translator: Translator { get }
    
}
