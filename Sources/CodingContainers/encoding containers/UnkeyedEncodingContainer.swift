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
    
    private(set) open var reference: Reference
    
    private var referencedMeta: UnkeyedContainerMeta {
        get {
            return reference.element as! UnkeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    public var encoder: MetaEncoder {
        
        return reference.coder as! MetaEncoder
        
    }
    
    open let codingPath: [CodingKey]
    
    open var count: Int {
        
        // during encoding this value needs to be known
        return referencedMeta.count!
        
    }
    
    private var lastCodingKey: CodingKey {
        
        return IndexCodingKey(intValue: self.count)!
        
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
        
        self.referencedMeta.append(element: try encoder.wrap(value, at: lastCodingKey ) )
        
    }
    
    // MARK: - nested container
    open func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // create path for nested container
        // at this point, count is the index at which nestedMeta will be inserted
        let path = codingPath + [ lastCodingKey ]
        
        let nestedMeta = encoder.translator.keyedContainerMeta()
        
        self.referencedMeta.append(element: nestedMeta)
        
        let nestedReference = DirectReference(coder: encoder, element: nestedMeta)
        
        return KeyedEncodingContainer( MetaKeyedEncodingContainer<NestedKey>(referencing: nestedReference, codingPath: path) )
        
    }
    
    open func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        
        let path = codingPath + [ lastCodingKey ]
        
        let nestedMeta = self.reference.coder.translator.unkeyedContainerMeta()
        
        self.referencedMeta.append(element: nestedMeta)
        
        let nestedReference = DirectReference(coder: encoder, element: nestedMeta)
        
        return MetaUnkeyedEncodingContainer(referencing: nestedReference, codingPath: path)
        
    }
    
    // MARK: - super encoder
    
    open func superEncoder() -> Encoder {
        
        let reference = UnkeyedContainerReference(coder: encoder, element: referencedMeta, index: count)
        return ReferencingMetaEncoder(referencing: reference)
        
    }
    
}
