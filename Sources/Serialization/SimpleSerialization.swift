//
//  SimpleSerialization.swift
//  MetaSerialization
//
//  Created by cherrywoods on 26.11.17.
//

import Foundation

/**
 Provides a simple Serialization structure, you pass a translator in initalization.
 SimpleSerialization uses that translator for all objects it serializes.
 */
public struct SimpleSerialization<R>: Serialization {
    
    public typealias Raw = R
    
    let translator: Translator
    
    public init(translator: Translator) {
        
        self.translator = translator
        
    }
    
    public func provideNewEncoder() -> MetaEncoder {
        
        return TranslatingCoder(translator: self.translator).encoder
        
    }
    
    public func provideNewDecoder(raw: R) -> MetaDecoder {
        
        return TranslatingCoder(translator: self.translator).decoder
        
    }
    
}
