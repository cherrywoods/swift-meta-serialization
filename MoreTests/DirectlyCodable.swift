//
//  DirectlyCodable.swift
//  MoreTests
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

import XCTest
import MetaSerialization

class DirectlyCodableTests: XCTestCase {
    
    func testDirecltyCodable() {
        
        let wrapper = BadWrapper(value: CoffeeLevel.testValue)
        let serialization = ShortExampleSerialization()
        
        let encoded = try! serialization.encode(wrapper)
        _ = try! serialization.decode(toType: BadWrapper<CoffeeLevel>.self, from: encoded)
        
    }
    
}

/// This wrapper calls `.encode(to:)` and `.init(from:)` directly
struct BadWrapper<T>: Codable where T: Codable {
    
    let value: T
    
    init(value: T) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        
        self.value = try T.init(from: decoder)
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        try value.encode(to: encoder)
        
    }
    
}

/// Used to test DirectlyCodable. Accepted by Example2 and Example3
struct CoffeeLevel: DirectlyCodable, LosslessStringConvertible {
    
    var description: String
    
    init?(level: Int) {
        
        switch level {
        case 0..<10:
            self.description = "very low"
        case 10..<30:
            self.description = "low"
        case 30..<70:
            self.description = "medium"
        case 70..<90:
            self.description = "high"
        case 90...100:
            self.description = "☕️⚡️"
        default:
            return nil
        }
        
    }
    
    init?(_ description: String) {
        
        guard ( (description == "very low") || (description == "low") || (description == "medium") || (description == "high") || (description == "☕️⚡️") ) else {
            return nil
        }
        
        self.description = description
        
    }
    
    static var testValue: CoffeeLevel {
        return CoffeeLevel(level: 91)!
    }
    
}
