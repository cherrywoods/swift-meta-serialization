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
    
    private var reference: ContainerReference
    
    // MARK: initalization
    
    /**
     Initalizes a new ReferencingMetaEncoder with the given values.
     
     This constructor uses StrictCodingStack as CodingStack implementation.
     - Parameter referening: A ContainerReference to the (encoding or decoding) container this referencing encoder will reference
     */
    public init(referencing reference: ContainerReference) {
        
        self.reference = reference
        
        // this Encoder needs to be initalized with the full coding path to make debugging possible
        super.init(at: reference.coder.codingPath,
                   with: reference.coder.userInfo,
                   translator: reference.coder.translator,
                   storage: reference.coder.storage.fork() )
        
    }
    
    // MARK: - deinitalization
    
    // flushes the meta object on stack to reference
    // this can only be done at this point, because before the meta object may be of a copy type (struct) and therefor not ready until now
    deinit {
        
        // if there were multiple elements on stack, the encoding process would have been interupted, or on entity managed to request two containers
        precondition( !storage.hasMultipleMetasInStorage, "ReferencingEncoder deinitalized holding multiple containers")
        
        let meta = try? storage.remove(at: codingPath)
        
        if meta != nil && meta! != nil {
            
            reference.insert(meta!!)
            
        }
        
    }
    
}
