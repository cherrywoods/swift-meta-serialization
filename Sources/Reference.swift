//
//  Reference.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

public protocol Reference {
    
    var coder: MetaCoder { get set }
    var element: Meta { get set }
    
}

public struct StackReference: Reference {
    
    public var coder: MetaCoder
    private let index: Int
    
    init(coder: MetaCoder, at index: Int) {
        self.coder = coder
        self.index = index
    }
    
    public var element: Meta {
        get {
            return coder.stack[index]
        }
        set {
            coder.stack[index] = newValue
        }
    }
    
}

public struct DirectReference: Reference {
    
    public var coder: MetaCoder
    public var element: Meta
    
    // default initalizer
    public init(coder: MetaCoder, element: Meta) {
        self.coder = coder
        self.element = element
    }
    
}

public protocol ContainerReference: Reference {
    var codingKey: CodingKey { get }
    mutating func insert(_: Meta)
}

public struct KeyedContainerReference: ContainerReference {
    
    public var coder: MetaCoder
    public var element: Meta {
        get {
            return keyedElement
        }
        set {
            if let keyed = newValue as? KeyedContainerMeta {
                keyedElement = keyed
            }
        }
    }
    
    private var keyedElement: KeyedContainerMeta
    public let codingKey: CodingKey
    
    public init(coder: MetaCoder, element: KeyedContainerMeta, at key: CodingKey) {
        self.coder = coder
        self.keyedElement = element
        self.codingKey = key
    }
    
    public mutating func insert(_ meta: Meta) {
        
        keyedElement[codingKey] = meta
        
    }
    
}

public struct UnkeyedContainerReference: ContainerReference {
    
    public var coder: MetaCoder
    public var element: Meta {
        get {
            return unkeyedElement
        }
        set {
            if let unkeyed = newValue as? UnkeyedContainerMeta {
                unkeyedElement = unkeyed
            }
        }
    }
    
    private var unkeyedElement: UnkeyedContainerMeta
    private let index: Int
    
    public init(coder: MetaCoder, element: UnkeyedContainerMeta, index: Int) {
        
        precondition(index >= 0, "index is smaller than 0")
        
        self.coder = coder
        self.unkeyedElement = element
        self.index = index
    }
    
    public var codingKey: CodingKey {
        return IndexCodingKey(intValue: index)! // index is >= 0 by precondition in inittalizer
    }
    
    public mutating func insert(_ meta: Meta) {
        
        unkeyedElement.insert(element: meta, at: index)
        
    }
    
}
