//
//  TranslatingCoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 23.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

public class TranslatingCoder {
    
    lazy internal var encoder: MetaEncoder = {
        return MetaEncoder(translator: translator)
    }()
    
    lazy internal var decoder: MetaDecoder = {
       return try! MetaDecoder(translator: translator, raw: raw)
    }()
    
    public let translator: Translator
    internal var raw: Representation?
    
    public init(translator: Translator) {
        self.translator = translator
    }
    
}
