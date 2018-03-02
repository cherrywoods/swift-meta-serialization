//
//  ContinueDecodingAfterError.swift
//  MetaSerializationTests macOS
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation

struct DecodesStrings: Codable {
    
    let value: [Int]
    
    init(_ value: Int...) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        // encode int array
        try container.encode(value)
        
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        // first try to decode a String array
        // which will fail and throw an error
        // and then decode Ints
        
        do {
            
            let strings = try container.decode([String].self)
            
            assertionFailure("Decoding Strings shouldn't be possible!")
            self.value = strings.flatMap { return Int($0) }
            
        } catch {
            
            // decode ints now
            self.value = try container.decode([Int].self)
            
        }
        
    }
    
}
