//
//  Forest.swift
//  MetaSerializationTests macOS
//
//  Created by cherrywoods on 21.12.17.
//

import Foundation

internal class Forest: Codable, Equatable {
    
    var location: String
    var trees: [Tree2]
    
    init( trees: [Tree2], location: String ) {
        self.trees = trees
        self.location = location
    }
    
    static func ==(lhs: Forest, rhs: Forest) -> Bool {
        
        return lhs.location == rhs.location && lhs.trees == rhs.trees
        
    }
    
}

internal class Tree2: Codable, Equatable {
    
    var height: Double
    var width: Double
    var age: Int
    var species: Tree.Species
    
    init( height: Double, width: Double, age: Int, kind: Tree.Species ) {
        self.height = height
        self.width = width
        self.age = age
        self.species = kind
    }
    
    static func ==(lhs: Tree2, rhs: Tree2) -> Bool {
        
        return lhs.height == rhs.height && lhs.width == rhs.width && lhs.age == rhs.age && lhs.species == rhs.species
        
    }
    
}

