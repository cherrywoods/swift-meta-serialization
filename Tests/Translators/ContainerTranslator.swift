//
//  ContainerTranslator.swift
//  MetaSerializationTests macOS
//
//  Created by cherrywoods on 07.02.18.
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
    
}

func encodeToContainer(_ input: Any?) -> Container {
    
    if input == nil {
        return Container.nil
    } else if input! is Bool {
        return Container.bool(input! as! Bool)
    } else if input! is String {
        return Container.string(input! as! String)
    } else if input! is Int {
        return Container.int(input! as! Int)
    } else if input! is Double {
        return Container.double(input! as! Double)
        
    } else if input! is [Any?] {
        
        return Container.array(input as! [Container])
        
    } else if input! is [String : Any?] {
        
        return Container.dictionary(input as! [String : Container])
        
    }
    
    // execution of this shows a bug
    preconditionFailure()
    
}

func decodeFromContainer(_ input: Any?) -> Any? {
    
    let container = input as! Container
    
    switch container {
    case .nil:
        return nil
    case .bool(let value):
        return value
    case .string(let value):
        return value
    case .int(let value):
        return value
    case .double(let value):
        return value
        
    case .array(let array):
        
        return array.map { decodeFromContainer($0) }
        
    case .dictionary(let dictionary):
        
        return dictionary.mapValues { decodeFromContainer($0) }
        
    }
    
}
