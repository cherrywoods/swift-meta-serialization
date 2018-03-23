//
//  MetaEncoder+containerMethods.swift
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

public extension MetaEncoder {

    public func container<Key: CodingKey>(keyedBy keyType: Key.Type) -> KeyedEncodingContainer<Key> {

        let path = codingPath

        // there needs to be a placeholder or a real meta stored at the path
        // if there is a meta stored at path and it isn't a KeyedContainerMeta, crash

        let alreadyStoringContainer = storage.storesMeta(at: path)
        if alreadyStoringContainer {

            guard storage[codingPath] is KeyedContainerMeta else {
                preconditionFailure("Requested a diffrent container type at a previously used coding path.")
            }

        }

        let reference = Reference.direct(storage, path)
        // only create a new container, if there isn't already one
        return container(keyedBy: keyType, referencing: reference, at: path, createNewContainer: !alreadyStoringContainer)

    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {

        let path = codingPath

        let alreadyStoringContainer = storage.storesMeta(at: path)
        if alreadyStoringContainer {

            guard storage[codingPath] is UnkeyedContainerMeta else {
                preconditionFailure("Requested a second container at a previously used coding path.")
            }

        }

        let reference = Reference.direct(storage, path)
        return unkeyedContainer(referencing: reference, at: path, createNewContainer: !alreadyStoringContainer)

    }

    public func singleValueContainer() -> SingleValueEncodingContainer {

        // A little bit strangely but not easily preventable,
        // a entity can request a keyed or unkeyed container
        // and then request a SingleValueContainer reffering to the meta of the keyed or unkeyed container.

        let path = codingPath
        let reference = Reference.direct(storage, path)

        return singleValueContainer(referencing: reference, at: path)

    }

}
