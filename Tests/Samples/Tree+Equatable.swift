//
//  Tree+Equatable.swift
//  meta-serializationTests
//
//  Created by cherrywoods on 26.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

extension Tree: Equatable {
    
    public static func ==(t1: Tree, t2: Tree) -> Bool {
        
        // compare trees by properties
        return t1.age == t2.age && t1.height == t2.height && t1.name == t2.name && t1.species == t2.species && t1.stem == t2.stem
        
    }
    
}

extension Branch: Equatable {
    
    public static func ==(b1: Branch, b2: Branch) -> Bool {
        
        // compare by properties
        // comparing the arrays should work, because they should recall == on each branch and will finaly succeede on the leafes, then children will be empty.
        return b1.length == b2.length && b1.children == b2.children
        
    }
    
}
