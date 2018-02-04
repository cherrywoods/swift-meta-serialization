//
//  MetaCoder.swift
//  meta-serialization
//
//  Created by cherrywoods on 15.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

// encoder will create a meta object

/// An Encoder that constucts a Meta entity insted of encoding directly to the desired format
open class MetaEncoder: Encoder, MetaCoder {
    
    public var userInfo: [CodingUserInfoKey : Any]
    
    /// the CodingStack of this encoder
    public var stack: CodingStack
    
    open var codingPath: [CodingKey] {
        return stack.codingPath
    }
    
    // MARK: - front end
    
    /**
     Encodes the given value.
     
     Use this method rather than directly calling encode(to:).
     encode(to:) will not detect types in the first place
     that are directly supported by the translator.
     Example: If data is a Data instance and the translator supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded as Data encodes itself.
     */
    open func encode<E, Raw>(_ value: E) throws -> Raw where E: Encodable {
        
        // encode over wrap function
        // this will keep E from encoding itself,
        // if it is supported by translator
        let meta = try wrap(value)
        return try representationOfEncodedValue(meta: meta)
        
    }
    
    /*
     Returns the representation or raw value of the value encoded to this encoder, if a value was already encoded to it and that encoding process has suceeded, otherwise it will throw an error.
     Throws: This function will throw an error, if the translation process in translator throws an error
     */
    open func representationOfEncodedValue<Raw>() throws -> Raw {
        
        // if there's not exectly one element on the stack, the encoding has not finished or has not suceeded
        guard stack.count == 1 else {
            throw MetaEncodingError.encodingProcessHasNotFinishedProperly
        }
        
        return try representationOfEncodedValue(meta: stack.first!)
        
    }
    
    internal func representationOfEncodedValue<Raw>(meta: Meta) throws -> Raw {
        
        // if stack.first is a PlaceholderMeta, an empty keyed container meta should be used (according to the documentation of encodable
        // a PlaceholderMeta may never be returned to an outside-framework entity
        let finalMeta = meta is PlaceholderMeta ? translator.keyedContainerMeta() : meta
        
        return try translator.encode(finalMeta)
        
    }
    
    /**
     Encodes the given intermediate value.
     Use this method if you encode other values inside your implementation of Encodable's encode(to:) method.
     
     Use this method rather than directly calling encode(to:), if you can not use a container.
     encode(to:) will not detect types in the first place
     that are directly supported by the translator.
     Example: If data is a Data instance and the translator supportes
     Data objects directly. Then calling data.encode(to:) will not fall back
     to that support, it will be encoded as Data encodes itself.
     */
    open func encodeIntermediate<E>(_ value: E) throws where E: Encodable {
        
        // encode over wrap function
        // this will keep E from encoding itself,
        // if it is supported by translator
        let meta = try wrap(value)
        // readd the meta to the stack
        try self.stack.push(meta: meta)
        
    }
    
    // MARK: - translator
    
    /// The translator used to get and finally translate Metas
    open let translator: Translator
    
    /// wraps an encodable value into a meta requested from translator.
    open func wrap<E>(_ value: E) throws -> Meta where E: Encodable {
        
        // On call of this method, two cases are possible.
        // Eighter the stack is at status .pathMissesMeta, in which case a keyed or unkeyed container
        // called this method, and value may eighter be supported directly by the translator,
        // or it may as well be encoded using value.encode(to: self)
        // that's possible, because stack's status is .pathMissingMeta,
        // and therefor value can request another container from this encoder.
        
        // The other case is, that stack is not at .pathMissesMeta,
        // in which case no new container may be added.
        // Therefor the only option for value is, that it's type is supported natively by translator
        
        // (note that this behavior defers as far as I can see from the one defined in JSONEncoder and PlistEncoder in the swift standard library. As I see it, in Foundation, one entity at one coding path may very well request nominaly two containers (but in the end there will be only one in the storage). This happens, as I read the code, if we got one of the (fileprivate) encoders passed to our own encodable class and requested a SingleValueContainer by the method with the same name. Now we may (maybe, I'm realy not so sure) request again a SingleValueContainer or any other container from this encoder, because it will not extend it's storage on the request of the first container and codingPath remains one element shorter than storage. This behavior may be intended, but it's confusing to me and conflicts with my understanding of the (short) documentation of SingleValueEncodingContainer, so this library will not allow an entity to request a single value container and then request a whole new keyed container with all subcontainers through the backdoor. (But in the swift standard library it's no problem anyway, because they are not adding containers to their storage in singleValueContainer()) )
        
        // whatever case we have, it's allways possible,
        // that translator supports the value's type natively
        if var newMeta = self.translator.wrappingMeta(for: value) {
            
            // if that is the case, set the value of newMeta and return it without ever using stack
            try newMeta.set(value: value)
            return newMeta
            
        }
        
        // ** now the value's type is not supported natively by translator **
        
        guard self.stack.mayPushNewMeta else {
            // this error is thrown, if an entity, that requested a single value container
            // was not supported natively by the translator
            throw EncodingError.invalidValue(value, EncodingError.Context.init(codingPath: self.codingPath, debugDescription: "Type \(type(of: value)) is not supported as primtive type by this serialization framework."))
        }
        
        // ** now it is sure, that stack will accept a new meta **
        
        // let value encode itself to this encoder
        try value.encode(to: self)
        
        // check whether encode really pushed a meta
        // in theory also removeLastCodingKey() could be called.
        // This can't be prevented without a 'protected' visibility modifier
        // as far as I can see.
        if self.stack.mayPopMeta {
            
            // in this case, value requested a container
            // this container is poped and returned
            // try! can be used without risk, because as we have checked, we may pop a meta
            return try! self.stack.pop()
            
        } else {
            
            // if value requests no container,
            // we are promted by the documention of Encodable to encode an empty keyed container
            return translator.keyedContainerMeta()
            
        }
        
    }
    
    // MARK: initalization
    
    /**
     Initalizes a new MetaEncoder with the given values.
     - Parameter translator: The translator the encoder will use to get and translate Metas.
     */
    public init(at codingPath: [CodingKey] = [], withUserInfo userInfo: [CodingUserInfoKey : Any] = [:], translator: Translator) {
        self.stack = CodingStack(at: codingPath)
        self.userInfo = userInfo
        self.translator = translator
    }
    
    // MARK: - container methods
    
    open func container<Key>(keyedBy keyType: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        
        // if there's no container at the current codingPath, let translator create a new one and append it
        // if there is one and it is a KeyedContainerMeta, its allright
        // otherwise crash the program
        do {
            try stack.push(meta: translator.keyedContainerMeta() )
        } catch /*StackError.statusMismatch .push trows no other errors*/ {
            
            // check wether the last meta is a KeyedContainerMeta
            guard stack.last is KeyedContainerMeta else {
                preconditionFailure("Requested a second container at the same coding path: \(codingPath)")
            }
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return KeyedEncodingContainer(
            MetaKeyedEncodingContainer<Key>(referencing: referencing, codingPath: self.codingPath)
        )
        
    }
    
    open func unkeyedContainer() -> UnkeyedEncodingContainer {
        
        // if there's no container at the current codingPath, let translator create a new one and append it
        // if there is one and it is a UnkeyedContainerMeta, its allright
        // otherwise crash the program
        do {
            try stack.push(meta: translator.unkeyedContainerMeta() )
        } catch /*StackError.statusMismatch .push throws no other errors*/ {
            
            // check wether the last meta is a KeyedContainerMeta
            guard stack.last is UnkeyedContainerMeta else {
                preconditionFailure("Requested a second container at the same coding path: \(codingPath)")
            }
        }
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return MetaUnkeyedEncodingContainer(referencing: referencing, codingPath: self.codingPath)
        
    }
    
    open func singleValueContainer() -> SingleValueEncodingContainer {
        
        // if there's no container at the current codingPath, insert a PlaceholderMeta
        // if there is a meta, continue with that one
        
        // this enables following behaviors:
        // An entity may request multiple containers for THE SAME meta, as it may do with the other two container methods
        // An old single value container can not be reused for another path
        // (this would be possible if MetaEncoder was extended to conform to SingleValueEncodingContainer)
        // A little bit strangely but not easily preventable,
        // a entity can request a keyed or unkeyed container
        // and then request a SingleValueContainer refering to the meta of the keyed or unkeyed container.
        // But thats all, it may request the container,
        // but will not be able to encode anything, or access the old container and it's values.
        // ( Note according to this, that an entity may completely legitimatelly request a single value container and encode anything that translator will map to the same Meta type, as it returns by keyedContainerMeta() or unkeyedContainerMeta(). This leads to the inverse situation from above, that the entity first request a single value container and is then able to request a keyed or unkeyed container again )
        
        if stack.mayPushNewMeta {
            try! stack.push(meta: PlaceholderMeta() )
        } // if an entity tried to encode twice at the same path, the single value container will throw an error, but this function will succeed
        
        let referencing = StackReference(coder: self, at: stack.lastIndex) as Reference
        return MetaSingleValueEncodingContainer(referencing: referencing, codingPath: self.codingPath)
        
    }
    
}

/// Used by superEncoder() in MetaKeyedEncodingContainer and MetaUnkeyedEncodingContainer
open class ReferencingMetaEncoder: MetaEncoder {
    
    private var reference: ContainerReference
    
    // MARK: initalization
    
    /**
     Initalizes a new SubEncoder with the given values.
     - Parameter referening: A ContainerReference to the (encoding or decoding) container this referencing encoder will reference
     */
    public init(referencing reference: ContainerReference) {
        
        self.reference = reference
        
        // this Encoder needs to be initalized with the full coding path to make debugging possible
        super.init(at: reference.coder.codingPath, translator: reference.coder.translator)
        
        // need to reinit stack, because it's codingKey does not contain reference.codingKey
        // and it would not allow to simply add a CodingKey
        // in the following configuration, stack starts at .pathFilled
        // and changes as reference.codingKey is added to .pathMissingMeta
        // (which is the status we want, so new containers can be requested)
        self.stack = CodingStack(at: reference.coder.codingPath, with: .pathFilled)
        try! self.stack.append(codingKey: reference.codingKey)
        
    }
    
    // MARK: - deinitalization
    
    // flushes the meta object on stack to reference
    // this can only be done at this point, because before the meta object may be a copy-type (struct) and therefor not ready until now
    deinit {
        
        // if there were multiple elements on stack, the encoding process would have been interupted, or on entity managed to request two containers
        precondition(stack.count <= 1, "ReferencingEncoder deinitalized holding multiple containers")
        
        // if there's no element on the stack, do nothing
        if let meta = stack.first {
            
            reference.insert(meta)
            
        }
        
    }
    
}
