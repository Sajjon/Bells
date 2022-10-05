//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-05.
//

import Foundation
import XCTest
@testable import Bells

/// `hash_to_G2` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/hash_to_G2.md
final class Ethereum_BLS12_381_Tests_HashToG2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_pop_vectors() async throws {
        try await doTestSuite(
            name: "ethereum_bls12-381-tests_hash_to_g2"
        ) { suite, vector, vectorIndex in
            let message = vector.input.msg.data(using: .utf8)!
            // https://github.com/ethereum/bls12-381-tests/blob/c01854d47b936b65404e5f08181f05db48792679/main.py#L102
            let dst: DomainSeperationTag = "QUUX-V01-CS02-with-BLS12381G2_XMD:SHA-256_SSWU_RO_"
            let hash = try await P2.hashToCurve(message: message, hashToFieldConfig: .init(domainSeperationTag: dst))
            let expected = try vector.output.p2()
            XCTAssertEqual(hash, expected)
        }
    }
}

private extension Ethereum_BLS12_381_Tests_HashToG2Tests {
    func doTestSuite(
        name: String,
        reverseVectorOrder: Bool = false,
        testVector: @escaping (HashToG2Suite, HashToG2Suite.Test, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: HashToG2Suite.Test.self,
            embedInSuite: { HashToG2Suite(tests: $0) },
            reverseVectorOrder: reverseVectorOrder,
            testVectorFunction: testVector
        )
    }
}

/// `hash_to_G2` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/hash_to_G2.md
struct HashToG2Suite: TestSuite, Decodable {
    struct Test: Decodable {
        struct Input: Decodable {
            /// Hex
            let msg: String
        }
        let input: Input
        let output: DecodableElement
    }
    var name: String { "hash_to_g2" }
    let tests: [Test]
}
