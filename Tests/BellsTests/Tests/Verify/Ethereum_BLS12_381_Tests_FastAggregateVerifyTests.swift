//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-08.
//

import Foundation
import XCTest
@testable import Bells
import CryptoKit

/// `fast_aggregate_verify` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/fast_aggregate_verify.md
final class Ethereum_BLS12_381_Tests_FastAggregateVerifyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_eth_fast_aggregate_verify_suite() async throws {
        try await doTestSuite(
            name: "ethereum_bls12-381-tests_fast_aggregate_verify"
        ) { [self] suite, vector, vectorIndex in
            try await doTestVector(vector, index: vectorIndex)
        }
    }
    
    
}

private extension Ethereum_BLS12_381_Tests_FastAggregateVerifyTests {
    
    func doTestVector(_ vector: FastAggregateVerify.Test, index vectorIndex: Int) async throws {
        do {
            let signature = try vector.expectedSignature()
            let publicKeys = try vector.publicKeys()
    
            let message = try await Message(hashing: vector.messageToHash(), domainSeperationTag: .g2Pop)
            
            let aggregatedPublicKey = try PublicKey.aggregate(publicKeys)
   

            let isValid = await aggregatedPublicKey.isValidSignature(signature, for: message)
            
            XCTAssertEqual(isValid, vector.isValid, "Expected \(vector.isValid), but got: \(isValid), vector: \(String(describing: vector))")
        } catch {
            XCTAssertFalse(vector.isValid)
        }

    }
    
    func doTestSuite(
        name: String,
        reverseVectorOrder: Bool = false,
        testVector: @escaping (FastAggregateVerify, FastAggregateVerify.Test, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: FastAggregateVerify.Test.self,
            embedInSuite: { FastAggregateVerify(tests: $0) },
            reverseVectorOrder: reverseVectorOrder,
            testVectorFunction: testVector
        )
    }
}

/// `fast_aggregate_verify` JSON tests from [`Ethereum bls12-381-tests`][source]
///
/// Manual copy paste of JSON object from each file in folder, into single array.
///
/// [source]: https://github.com/ethereum/bls12-381-tests/blob/master/formats/fast_aggregate_verify.md
private struct FastAggregateVerify: TestSuite, Decodable {
    struct Test: Decodable {
        struct Input: Decodable {
            /// Hex
            let message: String
            // Hex
            let pubkeys: [String]
            // hex
            let signature: String
        }
        let pubKeysAndMessageHashPrefix8: String?
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
        func publicKeys() throws -> [PublicKey] {
            try input.pubkeys.map {
                try .init(compressedData: Data(hex: $0))
            }
        }
    }
    var name: String { "fast_aggregate_verify" }
    let tests: [Test]
}
