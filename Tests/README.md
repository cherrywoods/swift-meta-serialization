#  Tests

Many of these tests are copies of the tests of JSONEncoder from swift, that can be found at https://github.com/apple/swift/blob/1e110b8f63836734113cdb28970ebcea8fd383c2/test/stdlib/TestJSONEncoder.swift.

These tests are licensed at the Apache 2.0 License with Runtime Library Exception. This license is contained in this repository in the file SWIFT-LICENSE.txt in the base folder.

Basically these tests were rewritten using Quick and Nimble. Some parts of the original file are also directly copied (and marked as copied).

The current tests cover:
 * general tests from JSONEncoder plus a few additionals
 *  `LinearCodingStack`
 * `CodingDictionary`
 * dynamic meta tree unwrapping
 * `StandardCodingKey` 
 * Representation
 * ErrorContainer
 
 Additional, a few smaller usability concepts are tested
  * Not allowing top level single value types
  * Not allowing nil values
