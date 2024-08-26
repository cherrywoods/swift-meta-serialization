//
//  Example1.swift
//  MetaSerializationTests macOS
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation
@testable import MetaSerialization

enum Example1 {
    
    static let translator = PrimitivesEnumTranslator(primitives: [ .nil, .bool, .string, .int, .double ])
    
    static let serialization = SimpleSerialization<Example1Container>(translator: Example1.translator,
                                                              encodeFromMeta: encodeToContainer,
                                                              decodeToMeta: decodeFromContainer)
    
}

func encodeToContainer(_ input: Meta) -> Example1Container {
    
    // input is eigther NilMarker, Bool, String, Int or Double
    
    if input is NilMarker {
        return Example1Container.nil
    } else if let bool = input as? Bool {
        return Example1Container.bool(bool)
    } else if let string = input as? String {
        return Example1Container.string(string)
    } else if let int = input as? Int {
        return Example1Container.int(int)
    } else if let double = input as? Double {
        return Example1Container.double(double)
        
    } else if let metaArray = input as? [Meta] {
        
        return  Example1Container.array( metaArray.map(encodeToContainer) )
        
    } else if let metaDictionary = input as? [String : Meta] {
        
        return Example1Container.dictionary( metaDictionary.mapValues(encodeToContainer) )
        
    }
    
    // execution of this shows a bug
    preconditionFailure()
    
}

func decodeFromContainer(_ container: Example1Container) -> Meta {
    
    switch container {
    case .nil:
        return NilMarker.instance
    case .bool(let value):
        return value
    case .string(let value):
        return value
    case .int(let value):
        return value
    case .double(let value):
        return value
        
    case .array(let array):
        
        return array.map(decodeFromContainer)
        
    case .dictionary(let dictionary):
        
        return dictionary.mapValues(decodeFromContainer)
        
    }
    
}
