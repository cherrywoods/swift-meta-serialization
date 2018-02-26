//
//  Tree.swift
//  meta-serializationTests
//
//  Created by cherrywoods on 26.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

// this classes are just test classes for encoding and decoding

public class Tree: Codable {
    
    public enum Species: String, Codable {
        
        case oak, lime, cherry, apple, peach, pear, spruce, plantane, maple
        
    }
    
    var stem: Branch
    var height: Float
    var age: Int
    var name: String
    var species: Species
    
    init(name: String = "", species: Species, age: Int, height: Float, numberOfBranches: Int) {
        
        self.name = name
        self.species = species
        self.age = age
        self.height = height
        
        // create the stem
        self.stem = Branch(numberOfChildren: numberOfBranches, length: height/3)
        
    }
    
}

public class Branch: Codable {
    
    // a leaf is a branch without children
    var children: [Branch]
    var length: Float
    
    init(numberOfChildren: Int, length: Float) {
        
        // create number of children leafs
        children = [Branch]()
        children.reserveCapacity(numberOfChildren)
        for _ in 0..<numberOfChildren {
            children.append( Branch(length: length) )
        }
        
        self.length = length
    }
    
    /// inits a leaf
    init(length: Float) {
        
        self.children = []
        self.length = length
        
    }
    
}

