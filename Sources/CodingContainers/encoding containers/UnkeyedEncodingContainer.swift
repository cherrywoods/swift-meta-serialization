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
    
    private var reference: Reference
    private var referencedMeta: UnkeyedContainerMeta {
        get {
            return reference.element as! UnkeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    var codingPath: [CodingKey]
    
    var count: Int {
        
        return referencedMeta.count
        
    }
    
    // MARK: - initalization
    
    public init(referencing reference: Reference, codingPath: [CodingKey]) {
        
        self.reference = reference
        self.codingPath = codingPath
        
    }
    
    // MARK: - encode
    
    func encodeNil() throws {
        try encode(GenericNil.instance)
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        
        // the coding path needs to be extended, because wrap(value) may throw an error
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.count)! )
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should acutally never happen
                // in one case, if wrap does not pop the added container again, wrap already throwed an error and this code will not be executed
                // in the other case, if wrap added no container, the same applies.
                // but I think it is better to crash the programm with a reason, than crash it without one using try!
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        
        let meta = try (self.reference.coder as! MetaEncoder).wrap(value)
        
        self.referencedMeta.append(element: meta)
        
    }
    
    // MARK: - nested container
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
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
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        
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
    
    func superEncoder() -> Encoder {
        
        let reference = UnkeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, index: self.count)
        return ReferencingMetaEncoder(referencing: reference)
        
    }
    
}
