//
//  AdditionalCodables.swift
//  MetaSerialization
//  
//  Copyright 2018-2024 cherrywoods
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
@testable import MetaSerialization

/// A button class that uses nested containers to encode and decode
class Button: Codable, Equatable {
    
    let label: String
    let color: String
    
    let position: (Int, Int)
    let size: (Int, Int)
    
    init(label: String, color: String, position: (Int, Int), size: (Int,Int)) {
        self.label = label
        self.color = color
        self.position = position
        self.size = size
    }
    
    private enum CodingKeys: CodingKey {
        
        case additionalInformation
        case size
        case position
        case x
        case y
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let topLevel = try decoder.container(keyedBy: CodingKeys.self)
        
        var infoContainer = try topLevel.nestedUnkeyedContainer(forKey: .additionalInformation)
        self.label = try infoContainer.decode(String.self)
        self.color = try infoContainer.decode(String.self)
        
        let sizeContainer = try topLevel.nestedContainer(keyedBy: CodingKeys.self, forKey: .size)
        self.size = ( try sizeContainer.decode(Int.self, forKey: .x), try sizeContainer.decode(Int.self, forKey: .y))
        
        let positionContainer = try topLevel.nestedContainer(keyedBy: CodingKeys.self, forKey: .position)
        self.position = ( try positionContainer.decode(Int.self, forKey: .x), try positionContainer.decode(Int.self, forKey: .y))
    }
    
    func encode(to encoder: Encoder) throws {
        
        var topLevel = encoder.container(keyedBy: CodingKeys.self)
        
        var infoContainer = topLevel.nestedUnkeyedContainer(forKey: .additionalInformation)
        try infoContainer.encode(label)
        try infoContainer.encode(color)
        
        var sizeContainer = topLevel.nestedContainer(keyedBy: CodingKeys.self, forKey: .size)
        try sizeContainer.encode(size.0, forKey: .x)
        try sizeContainer.encode(size.1, forKey: .y)
        
        var positionContainer = topLevel.nestedContainer(keyedBy: CodingKeys.self, forKey: .position)
        try positionContainer.encode(position.0, forKey: .x)
        try positionContainer.encode(position.1, forKey: .y)
        
    }
    
    static var testValue: Button {
        return Button(label: "click", color: "red", position: (20, 20), size: (20, 80))
    }
    
    static func == (lhs: Button, rhs: Button) -> Bool {
        
        return lhs.label == rhs.label &&
            lhs.color == rhs.color &&
            lhs.size.0 == rhs.size.0 && lhs.size.1 == rhs.size.1 &&
            lhs.position.0 == rhs.position.0 && lhs.position.1 == rhs.position.1
        
    }
    
}

class CoffeeDrinker: Person {
    
    var coffeeLevel: Int
    
    init(name: String, email: String, website: URL?, coffeeLevel: Int) {
        self.coffeeLevel = coffeeLevel
        super.init(name: name, email: email, website: website)
    }
    
    private enum CodingKeys: CodingKey {
        case coffeeLevel
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.coffeeLevel = try container.decode(Int.self, forKey: .coffeeLevel)
        
        try super.init(from: try container.superDecoder())
        
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(coffeeLevel, forKey: .coffeeLevel)
        
        try super.encode(to: container.superEncoder())
        
    }
    
    static override var testValue: CoffeeDrinker {
        return CoffeeDrinker(name: "Jane Doe", email: "jdoe@example.com", website: nil, coffeeLevel: 70)
    }
    
    static func ==(_ lhs: CoffeeDrinker, _ rhs: CoffeeDrinker) -> Bool {
        return lhs.isEqual(rhs) && lhs.coffeeLevel == rhs.coffeeLevel
    }
    
}

struct MultipleContainerRequestsType: Encodable {
    
    func encode(to encoder: Encoder) throws {
        _ = encoder.unkeyedContainer()
        _ = encoder.unkeyedContainer()
    }
    
}

struct ThrowingOnEncode: Encodable {
    
    func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "throwing on encode"))
    }
    
}

extension EitherDecodable: Equatable where T: Equatable, U: Equatable {
    
    static func == (lhs: EitherDecodable<T, U>, rhs: EitherDecodable<T, U>) -> Bool {
        
        switch (lhs, rhs) {
        case (.t(let lhValue), .t(let rhValue)):
            return lhValue == rhValue
        case (.u(let lhValue), .u(let rhValue)):
            return lhValue == rhValue
        default:
            return false
        }
        
    }
    
}
