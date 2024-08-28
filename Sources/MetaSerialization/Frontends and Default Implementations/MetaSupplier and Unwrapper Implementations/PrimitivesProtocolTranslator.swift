//
//  PrimitivesProtocolTranslator.swift
//  MetaSerialization
//  
//  Copyright 2018 cherrywoods
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 

import Foundation

/**
 This `MetaSupplier` and `Unwrapper` implementation provides an easy way to use MetaSerialization.
 
 To use it, define a marker protocol and extend your primitive types (the types you can represent directly in your end format, e.g. String, Int, etc...) to conform to it:
 ```
 protocol Primitive: Meta {}
 extension String: Primitive {}
 extension Int: Primitive {}
 ...
 ```
 If you wan't to allow nil values, extend NilMarker to conform to your marker protocol.
 
 Now create a PrimitivesProtocolTranslator with your marker protocol as generic Primitive parameter.
 If you pass this translator to a MetaEncoder, the encoder will create a meta tree that consists only of types conforming to your marker protocol,
 Array<Meta> where the elements will also conform to your marker protocol and Dictionary<String,Meta> (again conforming to marker) (the string keys aren't aviodable per se).
 These arrays and dictionaries may be arbitrarily nested. Note that the arrays (and dictionaries)
 will be of type Array<Meta> and not Array<YourMarkerProtocol> but you may safely assume that they conform to your marker protocol.
 
 The definition of PrimitivesProtocolTranslator does not require Primitive to conform to Meta.
 However all your types need to conform to meta, otherwise the encoding process will crash at some point.
 This requirement isn't implemented in the first place, because otherwise it was not possible to set Primitive to a protocol that simply.
 
 There is another issue right now: PrimitivesProtocolTranslator needs two Generic parameters because of an inconsistency in swift's type checking realted to protocols as generic paramters (https://bugs.swift.org/browse/SR-6872?jql=text%20~%20%22type%20check%20with%20protocol%22). If YourMarkerProtocol is your marker protocol the first type parameter should be YourMarkerProtocol and the second type should be YourMarkerProtocol.Type.
 ```
 protocol YourMarker: Meta {}
 let translator = PrimitivesProtocolTranslator<YourMarker, YourMarker.Type>()
 ```
 However, with this you may also specify two diffrent markers for encodign and decoding, since the first type will be used only during encoding and the second only during decoding.
 */
public struct PrimitivesProtocolTranslator<Primitive, PrimitiveType>: MetaSupplier, Unwrapper {
    
    // FIXME: implement the to meta constraint better if variadic generics get implemented
    
    public init() {}
    
    // use default implementations for containers.
    
    public func wrap<T>(_ value: T, for encoder: MetaEncoder) throws -> Meta? {
        
        if let primitive = value as? Primitive {
            
            precondition(primitive is Meta, "All types conforming to \(Primitive.self) need also to conform to Meta.")
            return (primitive as! Meta)
            
        } else {
            
            return nil
            
        }
        
    }
    
    public func unwrap<T>(meta: Meta, toType type: T.Type, for decoder: MetaDecoder) throws -> T? {
 
        // if type is a primtive and meta is T, it is unwrappend, otherwise not
        if type is PrimitiveType {
            
            return meta as? T
            
        } else {
            
            return nil
            
        }
        
    }
    
}
