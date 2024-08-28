//
//  PerformanceTestsCodables.swift
//  MetaSerialization
//  
//  Copyright 2018 cherrywoods
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 

import Foundation

/// A recursive tree structure (with controlable nesting grade)
struct Tree<T>: Codable where T: Codable {
    
    fileprivate var root: Node<T>
    
    init(dummy: T, depth: Int, width: Int) {
        
        root = Node(value: dummy, children: Tree.createTree(dummy: dummy, depth: depth - 1, width: width))
        
        
    }
    
    var depth: Int {
    
        var depth = 0
        var node = root
    
        while !node.children.isEmpty {
            depth += 1
            node = node.children.first!
        }
        
        return depth
        
    }
    
    /// recursively creates a tree of Nodes
    fileprivate static func createTree(dummy: T, depth: Int, width: Int) -> [Node<T>] {
        
        guard depth > 0 else {
            return [Node<T>](repeating: Node<T>(value: dummy, children: []), count: width)
        }
        
        // will use the one created node for all children, but since they all will be equal anyway it does not matter
        return [Node<T>](repeating: Node<T>(value: dummy, children: createTree(dummy: dummy, depth: depth-1, width: width)), count: width)
        
    }
    
}

fileprivate struct Node<T>: Codable where T: Codable {
    
    // will encode as: keyed: value: <value>
    //                        children: unkeyed: <children1>, ...
    
    let value: T
    var children: [Node<T>]
    
}
