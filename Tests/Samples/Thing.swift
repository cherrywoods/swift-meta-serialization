//
//  Thing.swift
//  MetaSerializationTests macOS
//
//  Created by cherrywoods on 05.02.18.
//

import Foundation

class Thing: Codable {
    
    let size: Dimensions
    let attributes: Attributes
    
    init(size: Dimensions, attributes: Attributes) {
        self.size = size
        self.attributes = attributes
    }
    
    // this struct used single value container
    // to encode and decode an array
    struct Dimensions: Codable {
        
        let heigth: Double
        let width: Double
        
        init(_ heigth: Double, _ width: Double) {
            self.heigth = heigth
            self.width = width
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.singleValueContainer()
            
            // FIXME: should work!
            let dims = try container.decode( [Double].self )
            
            self.heigth = dims[0]
            self.width = dims[1]
            
        }
        
        func encode(to encoder: Encoder) throws {
            
            var container = encoder.singleValueContainer()
            
            let dims = [ heigth, width ]
            
            try container.encode(dims)
            
        }
        
    }
    
    // codes using super(De|En)coder
    struct Attributes: Codable {
        
        let values: [String]
        
        init(_ values: String...) {
            self.values = values
        }
        
        init(from decoder: Decoder) throws {
            
            var container = try decoder.unkeyedContainer()
            
            var vals = [String]()
            
            while !container.isAtEnd {
                
                let superDecoder = try container.superDecoder()
                vals.append( try String(from: superDecoder) )
                
            }
            
            self.values = vals
            
        }
        
        func encode(to encoder: Encoder) throws {
            
            var container = encoder.unkeyedContainer()
            
            for value in values {
                
                let superEncoder = container.superEncoder()
                try value.encode(to: superEncoder)
                
            }
            
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case size
        case attributes
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.size = try container.decode(Dimensions.self, forKey: .size)
        self.attributes = try container.decode(Attributes.self, forKey: .attributes)
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(size, forKey: .size)
        try container.encode(attributes, forKey: .attributes)
        
    }
    
}

class NamedThing: Thing {
    
    let name: String
    
    init(size: Dimensions, attributes: Attributes, name: String) {
        self.name = name
        super.init(size: size, attributes: attributes)
    }
    
    enum CodingKeys2: String, CodingKey {
        case name
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys2.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        try super.init(from: decoder)
        
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys2.self)
        
        try container.encode(name, forKey: .name)
        
        try super.encode(to: encoder)
        
    }
    
}
