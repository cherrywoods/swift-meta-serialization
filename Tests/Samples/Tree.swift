//
//  Tree.swift
//  meta-serializationTests
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
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

