/*

 *********************************************************************************
 THIS FILE WAS MODIFIED!
 *********************************************************************************

 This file contains code licensed under the Apache v2 license,
 from the TestJSONEncoder file from swift's stdlib.

 You can find the original file at
 https://github.com/apple/swift/blob/1e110b8f63836734113cdb28970ebcea8fd383c2/test/stdlib/TestJSONEncoder.swift

 The original license is included in this repository
 in the file APACHE-LICENSE.txt.

 The parts from this file are marked with:
 // Lines 9 - 70 (the copies lines in the original file)
 // **************************** COPIED AND MODIFIED *****************************
 ... (copied code) ...
 // ******************************************************************************

 The code will have been modified. Modified lines are marked with // MODIFIED: line x
 where x is a placeholder for the line in the original file.
 Added and removed lines are marked in a similar manner.

 */

// TODO: number of *'s

import XCTest
@testable import MetaSerialization

class TestStateRestoringAfterThrow: XCTCase {

    // TODO: this test has no value for TestMetaSerialization
    // because it does not use a referencing encoder

    // Lines 802 - 831
    // **************************** COPIED AND MODIFIED *****************************
    // MARK: - Encoder State
    // SR-6078
    func testEncoderStateThrowOnEncode() {
        struct ReferencingEncoderWrapper<T : Encodable> : Encodable {
            let value: T
            init(_ value: T) { self.value = value }

            func encode(to encoder: Encoder) throws {
                // This approximates a subclass calling into its superclass, where the superclass encodes a value that might throw.
                // The key here is that getting the superEncoder creates a referencing encoder.
                var container = encoder.unkeyedContainer()
                let superEncoder = container.superEncoder()

                // Pushing a nested container on leaves the referencing encoder with multiple containers.
                var nestedContainer = superEncoder.unkeyedContainer()
                try nestedContainer.encode(value)
            }
        }

        // The structure that would be encoded here looks like
        //
        //   [[[Float.infinity]]]
        //
        // The wrapper asks for an unkeyed container ([^]), gets a super encoder, and creates a nested container into that ([[^]]).
        // We then encode an array into that ([[[^]]]), which happens to be a value that causes us to throw an error.
        //
        // The issue at hand reproduces when you have a referencing encoder (superEncoder() creates one) that has a container on the stack (unkeyedContainer() adds one) that encodes a value going through box_() (Array does that) that encodes something which throws (Float.infinity does that).
        // When reproducing, this will cause a test failure via fatalError().
        _ = try? serialization.encode(ReferencingEncoderWrapper([Double.infinity])) // MODIFIED: line 830
    }
    // ******************************************************************************

    // Lines 881 - 889
    // **************************** COPIED AND MODIFIED *****************************
    // MARK: - Decoder State
    // SR-6048
    func testDecoderStateThrowOnDecode() {
        // The container stack here starts as [[1,2,3]]. Attempting to decode as [String] matches the outer layer (Array), and begins decoding the array.
        // Once Array decoding begins, 1 is pushed onto the container stack ([[1,2,3], 1]), and 1 is attempted to be decoded as String. This throws a .typeMismatch, but the container is not popped off the stack.
        // When attempting to decode [Int], the container stack is still ([[1,2,3], 1]), and 1 fails to decode as [Int].
        // let json = "[1,2,3]".data(using: .utf8)!
        let container = Container.array( [ .int(1), .int(2), .int(3) ] ) // MODIFIED: line 887
        let _ = try! serialization.decode(toType: EitherDecodable<[String], [Int]>.self, from: container) // MODIFIED: line 888
    }
    // ******************************************************************************

}

// Lines 1507 - 1519
// **************************** COPIED AND MODIFIED *****************************
fileprivate enum EitherDecodable<T : Decodable, U : Decodable> : Decodable {
    case t(T)
    case u(U)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .t(try container.decode(T.self))
        } catch {
            self = .u(try container.decode(U.self))
        }
    }

}
// ******************************************************************************
