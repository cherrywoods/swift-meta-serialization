//
//  CodingStorage.swift
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

public struct CodingStorageError: Error {

    public enum Reason {

        /// Thrown if there's already a value stored a the given path.
        case alreadyStoringValueAtThisCodingPath

        /// Thrown if a meta was tried to be inserted for a coding path with more than one new key.
        case pathNotFilled

        /// Thrown if no meta is stored at the requested coding path.
        case noMetaStoredAtThisCodingPath

    }

    public let reason: Reason
    public let path: [CodingKey]

    public init(reason: Reason, path: [CodingKey]) {
        self.reason = reason
        self.path = path
    }

}

/**
 CodingStorage is the central storing unit of encoding as wall as decoding.

 It stores metas at coding paths (arrays of coding keys). Note that `[]` is also a valid path.

 The way how it stores them is implementation dependant and is correlated with the general abilities MetaSerialization can supply.

 In general, a single MetaEncoder or MetaDecoder will store and remove metas in a strictly linear manner.
 This means that this workflow is followed:

 store -> this workflow nested -> this workflow nested -> ... -> this workflow nested -> remove

 However multiple encoders/decoders can work on a single storage.
 This also depends on your implementation.
 All new encoders/decoders will call fork and use the storage returned by it.
 */
public protocol CodingStorage {

    /**
     Accesses the meta at the given coding path.

     You may not expect that you already stored a meta at codingPath.
     However you may expect, that the path is filled up to codingPath[0..<codingPath.endIndex-1].
     */
    subscript (codingPath: [CodingKey]) -> Meta { get set }

    /**
     Returns whether a meta is stored at the coding path.

     If a placeholder was requested for this path, return false.

     If this function returns true for a certain path, it must be safe to subscript to this path.
     */
    func storesMeta(at codingPath: [CodingKey]) -> Bool

    /**
     Stores a new meta at the coding path.

     If there's currently a placeholder stored at the given path, replace the placeholder.

     Throw CodingStorageErrors:
      - alreadyStoringValueAtThisCodingPath if the storage already stores a meta at the given coding path
      - pathNotFilled if there is no meta present for codingPath[0..<lastIndex-1]

     - Throws: `CodingStorageError`
     */
    func store(meta: Meta, at codingPath: [CodingKey]) throws

    /**
     Store a placeholder at the coding path.

     Throw CodingStorageErrors:
     - alreadyStoringValueAtThisCodingPath if the storage already stores a meta at the given coding path
     - pathNotFilled if there is no meta present for codingPath[0..<lastIndex-1]

     - Throws: `CodingStorageError`
     */
    func storePlaceholder(at codingPath: [CodingKey]) throws

    /**
     Remove the meta at the given coding path.

     Return nil, if a placeholder is stored at the path.
     Do also remove the placeholder.

     Throw CodingStorageErrors:
     - noMetaStoredAtThisCodingPath if no meta is stored at this coding path.

     - Throws: `CodingStorageError`
     */
    func remove(at codingPath: [CodingKey]) throws -> Meta?

    /**
     Return a CodingStoreage an new (super) encoder/decoder can work on.

     This new storage needs to be able to coop with coding paths for which values are stored in the
     storage fork is called on, but not in them teirselves.

     This means, that it is legitimate to call store(... at: [a, b, c]) on the storage returned by this function,
     if [a, b, c] was passed to fork, although there are no metas stored for [], [a] and [a, b] in the returned stroage.
     Accessing paths below the given coding path may fail.
      */
    func fork(at codingPath: [CodingKey]) -> CodingStorage

}
