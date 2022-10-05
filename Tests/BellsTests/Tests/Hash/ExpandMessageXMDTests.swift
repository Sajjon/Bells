//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-28.
//

import Foundation
import XCTest
@testable import Bells
import XCTAssertBytesEqual

@MainActor
final class ExpandMessageXMDTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        DefaultXCTAssertBytesEqualParameters.haltOnPatternNonIdentical = true
    }
    
    func test_message_xmd_SHA256_38() async throws {
        try await doTestSuite(name: "expand_message_xmd_SHA256_38") { suite, test, testIndex in
                let expanded = try await BLS.expandMessageXMD(
                    toLength: test.length(),
                    message: test.message(),
                    domainSeperationTag: suite.dst()
                )
                let expected = try test.expected()
                XCTAssertBytesEqual(expanded, expected)
        }
    }
    
    func test_message_xmd_SHA256_256() async throws {
        try await doTestSuite(name: "expand_message_xmd_SHA256_256") { suite, test, testIndex in
            if testIndex < 1 {
                let expanded = try await BLS.expandMessageXMD(
                    toLength: test.length(),
                    message: test.message(),
                    domainSeperationTag: suite.dst()
                )
                let expected = try test.expected()
                XCTAssertBytesEqual(expanded, expected)
            }
        }
    }
}

private extension ExpandMessageXMDTests {
    func doTestSuite(
        name: String,
        testVector: @escaping (XMDTestSuite, XMDTestSuite.Test, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: XMDTestSuite.self,
            testVectorFunction: testVector
        )
    }
}

/// {
///     "DST": "QUUX-V01-CS02-with-expander-SHA256-128",
///     "hash": "SHA256",
///     "k": 128,
///     "name": "expand_message_xmd",
///     "tests": [..]
/// }
struct XMDTestSuite: TestSuite, Decodable {
    let DST: String
    let hash: String
    let k: Int
    let name: String
    let tests: [Test]
    
    func dst(line: UInt = #line) throws -> DomainSeperationTag {
        let data = try XCTUnwrap(DST.data(using: .utf8), line: line)
        return .init(data: data)
    }
    
    ///  {
    ///      "DST_prime": "412717974da474d0f8c420f320ff81e8432adb7c927d9bd082b4fb4d16c0a23620",
    ///      "len_in_bytes": "0x20",
    ///      "msg": "abc",
    ///      "msg_prime":    "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000///      000000616263002000412717974da474d0f8c420f320ff81e8432adb7c927d9bd082b4fb4d16c0a23620",
    ///      "uniform_bytes": "52dbf4f36cf560fca57dedec2ad924ee9c266341d8f3d6afe5171733b16bbb12"
    ///  }
    struct Test: Decodable {
        let DST_prime: String
        let len_in_bytes: String
        let msg: String
        let msg_prime: String
        let uniform_bytes: String
        
        func length(line: UInt = #line) throws -> Int {
            let lengthAsHexString = len_in_bytes.starts(with: "0x") ? len_in_bytes.dropFirst(2)[...] : len_in_bytes[...]
            return try XCTUnwrap(Int(lengthAsHexString, radix: 16), line: line)
        }
        
        func message(line: UInt = #line) throws -> Data {
            try XCTUnwrap(msg.data(using: .utf8), line: line)
        }
        
        func messagePrime(line: UInt = #line) throws -> Data {
            try _unhex(hex: msg_prime, line: line)
        }
        
        func expected(line: UInt = #line) throws -> Data {
            try _unhex(hex: uniform_bytes, line: line)
        }
        
        func dstPrime(line: UInt = #line) throws -> DomainSeperationTag {
            try DomainSeperationTag(data: _unhex(hex: DST_prime, line: line))
        }
    }
}

func _unhex(hex: String, line: UInt = #line) throws -> Data {
    if hex.isEmpty {
        return Data()
    }
    XCTAssertNoThrow(try Data(hex: hex), line: line)
    return try Data(hex: hex)
}
