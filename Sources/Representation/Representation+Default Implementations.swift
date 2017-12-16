//
//  Representation+Default Implementations.swift
//  meta-serialization
//
//  Created by cherrywoods on 23.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

public extension Representation {
    
    public var encoder: MetaEncoder {
        return self.coder.encoder
    }
    
    public var decoder: MetaDecoder {
        return self.coder.decoder
    }
    
}

public extension EncodingRepresentation {
    
}

public extension DecodingRepresentation {
    
}
