//
//  Reference.swift
//  MetaSerialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

// MARK: new

/**
 A reference to some meta, eigther on the storage, or inside another container meta.
 
 References are used to rewrite copy types directly to the place where they are stored.
 */
public enum Reference {
    
    /// A reference directly to the coding storage
    case direct( CodingStorage, [CodingKey] )
    /// A reference to an element inside another container.
    case containerElement( ContainerElementReference )
    
    /// The referenced meta.
    var meta: Meta {
        
        get {
            
            switch(self) {
            case .direct(let storage, let path):
                return storage[path]
            case .containerElement(let containerReference):
                return containerReference.meta
            }
            
        }
        
        set {
            
            switch(self) {
            case .direct(var storage, let path):
                storage[path] = newValue
            case .containerElement(var containerReference):
                containerReference.insert( newValue )
            }
            
        }
        
    }
    
}

/**
 References a value inside another container meta.
 */
public protocol ContainerElementReference {
    
    var meta: Meta { get }
    mutating func insert(_ meta: Meta)
    
}

/**
 References an element in any keyed container meta. This meta may be in the storage of another container or directly on the stack.
 */
public struct KeyedContainerElementReference: ContainerElementReference {
    
    private var reference: Reference
    private let key: CodingKey
    
    private var container: KeyedContainerMeta {
        
        get {
            return (reference.meta as! KeyedContainerMeta)
        }
        
        set {
            reference.meta = newValue
        }
        
    }
    
    /**
     Inits a new keyed container element reference.
     
     - Parameter ref: The underlying reference.
     - codingKey: The codingKey that identifies the element to reference.
     */
    public init(referencing ref: Reference, at codingKey: CodingKey) {
        
        precondition(ref.meta is KeyedContainerMeta, "ref.meta needs to be a KeyedContainerMeta.")
        
        self.reference = ref
        self.key = codingKey
        
    }
    
    public var meta: Meta {
        
        return container[key]!
        
    }
    
    public mutating func insert(_ meta: Meta) {
        
        container[key] = meta
        
    }
    
}

/**
 References an element in any unkeyed container meta. This meta may be in the storage of another container or directly on the stack.
 */
public struct UnkeyedContainerElementReference: ContainerElementReference {
    
    private var reference: Reference
    private let index: Int
    
    private var container: UnkeyedContainerMeta {
        
        get {
            return (reference.meta as! UnkeyedContainerMeta)
        }
        
        set {
            reference.meta = newValue
        }
        
    }
    
    /**
     Inits a new unkeyed container element reference.
     
     Before calling this method, make sure that ref.meta is a UnkeyedContainerMeta and contains codingKey.
     
     - Parameter ref: The underlying reference.
     - index: The index to access. This index needs to be valid.
     */
    public init(referencing ref: Reference, at index: Int) {
        
        precondition(ref.meta is UnkeyedContainerMeta, "ref.meta needs to be a UnkeyedContainerMeta.")
        
        self.reference = ref
        self.index = index
        
    }
    
    public var meta: Meta {
        
        return container.get(at: index)!
        
    }
    
    public mutating func insert(_ meta: Meta) {
        
        container.insert(element: meta, at: index)
        
    }
    
}