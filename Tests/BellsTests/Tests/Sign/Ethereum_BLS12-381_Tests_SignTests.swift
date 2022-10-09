//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-10-05.
//

import Foundation
import XCTest
@testable import Bells

/// `sign` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/sign.md
final class Ethereum_BLS12_381_Tests_SignTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_eth_sign_suite() async throws {
        try await doTestSuite(
            name: "ethereum_bls12-381-tests_sign"
        ) { suite, vector, vectorIndex in
            let privateKey = try PrivateKey(scalar: .init(hex: vector.input.privkey))
            let messageToHash = try Data(hex: vector.input.message)
            let (signature, message) = try await privateKey._sign(hashing: messageToHash, domainSeperationTag: .g2Pop)
            let expected = try Signature(compressedData: Data(hex: vector.output))
            XCTAssertEqual(signature, expected)
            let isValid = await privateKey.publicKey().isValidSignature(signature, for: message)
            XCTAssertTrue(isValid)
        }
    }
}

private extension Ethereum_BLS12_381_Tests_SignTests {
    func doTestSuite(
        name: String,
        reverseVectorOrder: Bool = false,
        testVector: @escaping (SignSuite, SignSuite.Test, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: SignSuite.Test.self,
            embedInSuite: { SignSuite(tests: $0) },
            reverseVectorOrder: reverseVectorOrder,
            testVectorFunction: testVector
        )
    }
}

/// `sign` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/sign.md
private struct SignSuite: TestSuite, Decodable {
    struct Test: Decodable {
        struct Input: Decodable {
            /// Hex
            let message: String
            // Hex
            let privkey: String
        }
        let input: Input
        let output: String
    }
    var name: String { "sign" }
    let tests: [Test]
}
