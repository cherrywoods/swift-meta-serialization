//
//  ArrayUnkeyedMeta.swift
//  meta-serialization
//
//  Created by cherrywoods on 24.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

open class ArrayUnkeyedContainerMeta: UnkeyedContainerMeta, GenericMeta {
    
    public typealias SwiftValueType = [Meta]
    
    // this init exists, because somehow otherweise no initalizer would be publicly visible
    public init() {
        // init with default value
    }
    
    /**
     The arry value of this container.
     
     Note that you may never set it to nil and that it never will be nil.
     */
    open var value: [Meta]? = [] {
        willSet {
            // this precondition enables the save use of ! in the implementations below
            precondition(newValue != nil,
                         "The value property of an ArrayUnkeyedContainerMeta may never be nil. Do not set it to nil. If you wan't to delete all key-value-pairs, set it to [].")
        }
    }
    
    open var count: Int {
        return value!.count
    }
    
    open func get(at index:Int) -> Meta? {
        guard (0..<count).contains(index) else { // makes sure index is within its valid bounds (0 and count)
            return nil
        }
        return value![index]
    }
    
    open func insert(element: Meta, at index: Int) {
        value!.insert(element, at: index)
    }
    
    open func append(element: Meta) {
        value!.append(element)
    }
    
}
