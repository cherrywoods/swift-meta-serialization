//
//  ReferencingMetaDecoder.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
// 

import Foundation

/// Used by superDecoder() in MetaKeyedDecodingContainer and MetaUnkeyedDecodingContainer
open class ReferencingMetaDecoder: MetaDecoder {
    
    private var reference: ContainerReferenceProtocol
    
    // MARK: initalization
    
    /**
     Initalizes a new SubEncoder with the given values.
     
     This constructor uses StrictCodingStack as CodingStack implementation.
     - Parameter referening: A ContainerReference to the (encoding or decoding) container this referencing encoder will reference
     - Parameter meta: The meta that should be decoded by this decoder
     */
    public init(referencing reference: ContainerReferenceProtocol, meta: Meta) {
        
        self.reference = reference
        
        let codingPath = reference.coder.codingPath + [reference.codingKey]
        
        super.init(at: codingPath,
                   with: reference.coder.userInfo,
                   translator: reference.coder.translator,
                   // new storage should tolerate coding paths longer than reference.coder's coding path
                   storage: reference.coder.storage.fork(at: codingPath))
        
    }
    
    // Note: referencing Decoders should not flush back their results to the reference they have
    
}
