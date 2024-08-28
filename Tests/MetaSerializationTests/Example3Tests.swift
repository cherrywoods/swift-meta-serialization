//
//  Example3Tests.swift
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

import Quick
import Nimble
@testable import MetaSerialization

class Example3Spec: QuickSpec {
    
    override class func spec() {
        
        let standardTests = StandardBehavior(serialization: Example3.serialization, qs: self)
        standardTests.test(expected: [ "empty" : "keyed;",
                                       "empty unkeyed" : "unkeyed;",
                                       "person" : "keyed;*name*:*Johnny Appleseed*,*email*:*appleseed@apple.com*,",
                                       "EnhancedBool.true" : "*true*",
                                       "EnhancedBool.false" : "*false*",
                                       "EnhancedBool.fileNotFound" : "*nil*",
                                       "wrapped(EnhancedBool.true)" : "keyed;*value*:*true*,",
                                       "wrapped(EnhancedBool.false)" : "keyed;*value*:*false*,",
                                       "wrapped(EnhancedBool.fileNotFound)" : "keyed;*value*:*nil*" ],
                           allowTopLevelSingleValues: true, allowNestedContainers: false, allowNils: false)
        
    }
    
}
