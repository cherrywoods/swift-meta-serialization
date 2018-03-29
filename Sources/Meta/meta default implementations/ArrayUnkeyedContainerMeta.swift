//
//  ArrayUnkeyedMeta.swift
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

// TODO: replace with array extension

open class ArrayUnkeyedContainerMeta: UnkeyedContainerMeta, GenericMeta {
    
    public typealias SwiftValueType = [Meta]
    
    public required init(value: [Meta] = []) {
        
        self.value = value
        
    }
    
    /**
     The array value of this container.
     */
    open var value: [Meta]
    
    open var count: Int {
        return value.count
    }
    
    open func get(at index:Int) -> Meta? {
        guard (0..<count).contains(index) else { // makes sure index is within its valid bounds (0 and count)
            return nil
        }
        return value[index]
    }
    
    open func insert(element: Meta, at index: Int) {
        value.insert(element, at: index)
    }
    
    open func append(element: Meta) {
        value.append(element)
    }
    
}
