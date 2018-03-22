//
//  Array+UnkeyedContainerMeta.swift
//  MetaSerialization
//  
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense. 
//  See https://www.unlicense.org
//

#if swift(>=4.1)
    
import Foundation
    
extension Array: UnkeyedContainerMeta, Meta where Element: Meta {
    
    // TODO: no overlap? really works? should rename count to numberOfElements?
    public var count: Int? {
        return (self as Array<Meta>).count
    }
    
    public func get(at index:Int) -> Meta? {
        
        guard (0..<count).contains(index) else { // makes sure index is within its valid bounds (0 and count)
            return nil
        }
        return self[index]
        
    }
    
    public func insert(element: Meta, at index: Int) {
        self.insert(element: element, at: index)
    }
    
    public func append(element: Meta) {
        self.append(element: element)
    }
    
}
    
#endif
