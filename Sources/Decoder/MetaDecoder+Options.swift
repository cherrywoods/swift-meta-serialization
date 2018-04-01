//
//  MetaDecoder+Options.swift
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

extension MetaDecoder {
    
    public struct Options: OptionSet {
        
        public typealias RawValue = Int
        public var rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        // MARK: options
        
        /**
         For each meta in the meta tree `unwrapper.unwrap` is called before decoding takes place for it.
         
         This option allows you to partially postpone the creation of the meta tree until the actual containers are known.
         
         Specifically, if keyed or unkeyed containers are requested for a meta,
         before this meta is interpreted as keyed or unkeyed container and it is expected that it conforms to `DecodingKeyedContainerMeta` respectively `DecodingUnkeyedContainerMeta`,
         `unwrapper.unwrap` is called, with eigther `DecodingKeyedContainerMeta` or `DecodingUnkeyedContainerMeta` for type.
         If `unwrap` returns nil, the process continues with the original meta.
         
         Ot enable this behavior, your unwrapper also needs to conform to `ContainerUnwrapper`.
         
         With this behavior, you may now dynamically extend your meta tree.
         You don't need to know which meta will be a keyed or unkeyed container
         and don't need meta implementations to conform to `Decoding(Un)KeyedContainerMeta` if they could be seen as such containers.
         */
        public static let dynamicallyUnwindMetaTree = Options(rawValue: 1 << 0)
        
        // MARK: combinations
        
        /// The default configuration `[]` of a decoder.
        public static let defaultConfiguration: Options = []
        
    }
    
}
