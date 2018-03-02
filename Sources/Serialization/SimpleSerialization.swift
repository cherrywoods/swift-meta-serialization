//
//  SimpleSerialization.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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
    
    public func provideNewDecoder() -> MetaDecoder {
        
        return MetaDecoder(translator: translator)
        
    }
    
}
