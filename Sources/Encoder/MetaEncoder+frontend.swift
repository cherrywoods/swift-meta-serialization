//
//  MetaEncoder+frontend.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See www.unlicense.org
// 

import Foundation

public extension MetaEncoder {
    
    /**
     Encodes the given value.
     
     Use this method rather than directly calling encode(to:).
     encode(to:) will not detect types in the first place
     that are directly supported by the translator.
     
     Example: If data is a Data instance and the translator supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded the way Data encodes itself.
     */
    public func encode<E, Raw>(_ value: E) throws -> Raw where E: Encodable {
        
        // encode over wrap function
        // this will keep E from encoding itself,
        // if it is supported by translator
        
        // if value didn't encode an empty keyed container meta should be used
        // (according to the documentation of Encodable)
        let meta = try wrap(value)
        
        return try translator.encode(meta)
        
    }
    
}
