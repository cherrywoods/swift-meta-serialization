//
//  LinuxMain.swift
//  MetaSerialization
//  
//  Copyright 2024 cherrywoods
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
import Quick

@testable import MetaSerializationTests
@testable import TestAssertionGuarded 

@main struct Main {
    static func main() {
        Quick.QCKMain(
            [CodingKeySpec.self, Example1Spec.self, Example2Spec.self, Example3Spec.self], 
            configurations: [], 
            testCases: [
                testCase(PerformanceTests.allTests), 
                testCase(DirectlyCodableTests.allTests),
                testCase(TestCodingStorageErrorCatching.allTests),
            ]
        )
    }
}
