//
//  UnkeyedEncodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

/**
 Manages a UnkeyedContainerMeta
 */
open class MetaUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    // MARK: properties
    
    /**
     A reference to this containers underlying `UnkeyedContainerMeta`
     */
    open var reference: Reference
    
    /**
     The encoder that created this container.
     
     Encoding, creating new containers and creating super encoders is delegated to it.
     */
    open let encoder: MetaEncoder
    
    open let codingPath: [CodingKey]
    
    // MARK: utilities
    
    private var referencedMeta: UnkeyedContainerMeta {
        
        get {
            
            return reference.meta as! UnkeyedContainerMeta
            
        }
        
        set {
            
            reference.meta = newValue
            
        }
        
    }
    
    private var lastCodingKey: CodingKey {
        return createCodingKey(for: count)
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, at codingPath: [CodingKey], encoder: MetaEncoder) {
        
        precondition(reference.meta is UnkeyedContainerMeta, "reference.meta needs to conform to KeyedContainerMeta")
        
        self.reference = reference
        self.codingPath = codingPath
        self.encoder = encoder
        
    }
    
    // MARK: count
    
    open var count: Int {
        
        // during encoding this value needs to be known
        return referencedMeta.count!
        
    }
    
    // MARK: - encode
    
    open func encodeNil() throws {
        
        try encode(GenericNil.instance)
        
    }
    
    public func encode<T: Encodable>(_ value: T) throws {
        
        referencedMeta.insert(element: try encoder.wrap(value, at: lastCodingKey ), at: count )
        
    }
    
    // MARK: - nested container
    
    public func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        
        return encoder.container(keyedBy: keyType,
                                 referencing: createElementReference(for: count),
                                 at: codingPath + [lastCodingKey])
        
    }
    
    public func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        
        return encoder.unkeyedContainer(referencing: createElementReference(for: count),
                                        at: codingPath + [lastCodingKey])
        
    }
    
    // MARK: - super encoder
    
    public func superEncoder() -> Encoder {
        
        return encoder.encoder(referencing: createElementReference(for: count),
                                    at: codingPath + [lastCodingKey])
        
    }
    
    // MARK: - overridable methods
    
    /// create a coding key for the given index
    open func createCodingKey(for index: Int) -> CodingKey {
        
        return IndexCodingKey(intValue: index)!
        
    }
    
    /**
     Create a new reference for the element at the given index.
     
     nestedContainer, nestedUnkeyedContainer and superEncoder use this method to create element references.
     */
    open func createElementReference(for index: Int) -> Reference {
        
        let elementRef = UnkeyedContainerElementReference(referencing: reference, at: index)
        return Reference.containerElement( elementRef )
        
    }
    
}
