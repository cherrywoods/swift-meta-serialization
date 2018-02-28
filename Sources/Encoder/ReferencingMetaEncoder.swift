//
//  ReferencingMetaEncoder.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

/// Used by superEncoder() in MetaKeyedEncodingContainer and MetaUnkeyedEncodingContainer
open class ReferencingMetaEncoder: MetaEncoder {
    
    private var reference: Reference
    
    // MARK: initalization
    
    /**
     Initalizes a new ReferencingMetaEncoder with the given values.
     
     This constructor uses StrictCodingStack as CodingStack implementation.
     - Parameter referening: A ContainerReference to the (encoding or decoding) container this referencing encoder will reference
     */
    public init(referencing reference: Reference,
                at codingPath: [CodingKey],
                with userInfo: [CodingUserInfoKey : Any],
                translator: Translator,
                storage: CodingStorage) {
        
        self.reference = reference
        
        super.init(at: codingPath,
                   with: userInfo,
                   translator: translator,
                   // new storage should tolerate coding paths longer than reference.coder's coding path
                   storage: storage )
        
        // store placeholder at the root path
        try! storage.storePlaceholder(at: codingPath)
        try! storage.lock(codingPath: codingPath)
        
    }
    
    // MARK: - deinitalization
    
    // flushes the meta object on stack to reference
    // this can only be done at this point, because before the meta object may be of a copy type (struct) and therefor not ready until now
    deinit {
        
        // if there were multiple elements on stack, the encoding process would have been interupted, or on entity managed to request two containers
        precondition( !storage.hasMultipleMetasInStorage, "ReferencingEncoder deinitalized holding multiple containers")
        
        // coding path should the initial coding path again.
        
        storage.unlock(codingPath: codingPath)
        
        // because we stored a placeholder and locked, storage should not miss a meta at codingPath
        reference.meta = try! storage.remove(at: codingPath) ?? translator.keyedContainerMeta()
        
    }
    
}
