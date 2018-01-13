//
//  UnkeyedEncodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 16.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 Manages a UnkeyedContainerMeta
 */
open class MetaUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    private(set) open var reference: Reference
    open var referencedMeta: UnkeyedContainerMeta {
        get {
            return reference.element as! UnkeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    open var codingPath: [CodingKey]
    
    open var count: Int {
        
        return referencedMeta.count
        
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    // MARK: - encode
    
    open func encodeNil() throws {
        try encode(GenericNil.instance)
    }
    
    open func encode<T: Encodable>(_ value: T) throws {
        
        // the coding path needs to be extended, because wrap(value) may throw an error
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.count)! )
        
        let meta = try (self.reference.coder as! MetaEncoder).wrap(value)
        
        self.referencedMeta.append(element: meta)
        
        // do not use defer here, because a failure indicates corrupted data
        // and that should be reported in a error
        try reference.coder.stack.removeLastCodingKey()
        
    }
    
    // MARK: - nested container
    open func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        // at this point, count is the index at which nestedMeta will be inserted
        self.codingPath.append( IndexCodingKey(intValue: self.count)! )
        defer { self.codingPath.removeLast() }
        
        let nestedMeta = self.reference.coder.translator.keyedContainerMeta()
        
        self.referencedMeta.append(element: nestedMeta)
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        return KeyedEncodingContainer(
            MetaKeyedEncodingContainer<NestedKey>(referencing: nestedReference, codingPath: self.codingPath)
        )
        
    }
    
    open func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        
        // key needs to be added, because it is passed to the new MetaKeyedEncodingContainer
        // at this point, count is the index at which nestedMeta will be inserted
        self.codingPath.append( IndexCodingKey(intValue: self.count)! )
        defer { self.codingPath.removeLast() }
        
        let nestedMeta = self.reference.coder.translator.unkeyedContainerMeta()
        
        self.referencedMeta.append(element: nestedMeta)
        
        let nestedReference = DirectReference(coder: self.reference.coder, element: nestedMeta)
        
        return MetaUnkeyedEncodingContainer(referencing: nestedReference, codingPath: self.codingPath)
        
    }
    
    // MARK: - super encoder
    
    open func superEncoder() -> Encoder {
        
        let reference = UnkeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, index: self.count)
        return ReferencingMetaEncoder(referencing: reference)
        
    }
    
}
