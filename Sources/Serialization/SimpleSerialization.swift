//
//  SimpleSerialization.swift
//  MetaSerialization
//
//  Created by cherrywoods on 26.11.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 Provides a simple Serialization class, you pass a translator in initalization.
 SimpleSerialization uses that translator for all objects it serializes.
 */
public class SimpleSerialization<R>: Serialization {
    
    public typealias Raw = R
    
    let translator: Translator
    
    public init(translator: Translator) {
        
        self.translator = translator
        
    }
    
    public func provideNewEncoder() -> MetaEncoder {
        
        return MetaEncoder(translator: translator)
        
    }
    
    public func provideNewDecoder(raw: R) -> MetaDecoder {
        
        return try! MetaDecoder(translator: translator, raw: raw)
        
    }
    
}
