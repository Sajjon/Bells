//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-08.
//

import Foundation
import XCTest
@testable import Bells

/// `verify` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/verify.md
final class Ethereum_BLS12_381_Tests_VerifyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_eth_verify_suite() async throws {
        try await doTestSuite(
            name: "ethereum_bls12-381-tests_verify"
        ) { suite, vector, vectorIndex in
            do {
                let publicKey = try vector.publicKey()
                let signature = try vector.expectedSignature()
                let message = try await Message(hashing: vector.messageToHash(), domainSeperationTag: .g2Pop)
                let isValid = await publicKey.isValidSignature(signature, for: message)
                XCTAssertEqual(isValid, vector.isValid)
            } catch {
                XCTAssertFalse(vector.isValid)
            }

        }
    }
}

private extension Ethereum_BLS12_381_Tests_VerifyTests {
    func doTestSuite(
        name: String,
        reverseVectorOrder: Bool = false,
        testVector: @escaping (VerifySuite, VerifySuite.Test, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: VerifySuite.Test.self,
            embedInSuite: { VerifySuite(tests: $0) },
            reverseVectorOrder: reverseVectorOrder,
            testVectorFunction: testVector
        )
    }
}

/// `verify` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/verify.md
private struct VerifySuite: TestSuite, Decodable {
    struct Test: Decodable {
        struct Input: Decodable {
            /// Hex
            let message: String
            // Hex
            let pubkey: String
            // hex
            let signature: String
        }
        let input: Input
        
        // `isValid`
        let output: Bool
        var isValid: Bool { output }
        
        func expectedSignature() throws -> Signature {
            try .init(compressedData: Data(hex: input.signature))
        }
        func messageToHash() throws -> Data {
            try Data(hex: input.message)
        }
        func publicKey() throws -> PublicKey {
            try .init(compressedData: Data(hex: input.pubkey))
        }
    }
    var name: String { "verify" }
    let tests: [Test]
}

