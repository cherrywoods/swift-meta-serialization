//
//  ContainerTranslator.swift
//  MetaSerializationTests macOS
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//

import Foundation
@testable import MetaSerialization

enum Container {
    
    case `nil`
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case array([Container])
    case dictionary([String:Container])
    
    static let translator = PrimitivesEnumTranslator(primitives: [ .nil, .bool, .string, .int, .double ])
    
}

func encodeToContainer(_ input: Meta) -> Container {
    
    // input is eigther NilMarker, Bool, String, Int or Double
    
    if input is NilMarker {
        return Container.nil
    } else if let bool = input as? Bool {
        return Container.bool(bool)
    } else if let string = input as? String {
        return Container.string(string)
    } else if let int = input as? Int {
        return Container.int(int)
    } else if let double = input as? Double {
        return Container.double(double)
        
    } else if let metaArray = input as? [Meta] {
        
        return  Container.array( metaArray.map(encodeToContainer) )
        
    } else if let metaDictionary = input as? [String : Meta] {
        
        return Container.dictionary( metaDictionary.mapValues(encodeToContainer) )
        
    }
    
    // execution of this shows a bug
    preconditionFailure()
    
}

func decodeFromContainer(_ container: Container) -> Meta {
    
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
