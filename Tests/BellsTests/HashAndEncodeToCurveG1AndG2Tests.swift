//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-12.
//

import Foundation
import XCTest
@testable import Bells
import XCTAssertBytesEqual
import BytesMutation
import BigInt

@MainActor
final class HashToCurveG1Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        DefaultXCTAssertBytesEqualParameters.haltOnPatternNonIdentical = true
    }
    
    
    func test_hash_to_curve_g2_RO() async throws {
        try await doTestG2(
            name: "BLS12381G2_XMD_SHA-256_SSWU_RO_"
        )
    }
    
    
//    func test_hash_to_curve_g1_RO() async throws {
//        try await doTestG1(
//            name: "BLS12381G1_XMD_SHA-256_SSWU_RO_"
//        )
//    }
    
//    func test_hash_to_curve_g1_NU() async throws {
//        try await doTestG1(
//            name: "BLS12381G1_XMD_SHA-256_SSWU_NU_"
//        )
//    }
//
//    func test_hash_to_curve_g2_NU() async throws {
//        try await doTestG2(
//            name: "BLS12381G2_XMD_SHA-256_SSWU_NU_"
//        )
//    }

 
}

extension Fp {
    init(data: Data) {
        self.init(value: .init(data: data))
    }
}

func bigInt(
    hexConcatenated: String
) throws -> (BigInt, BigInt) {
    // The vector contains REAL and IMG concat together with ","
    let hexParts = hexConcatenated.split(separator: ",").map(String.init)
    let (hex0, hex1) = (hexParts[0], hexParts[1])
    let data0 = try Data(hex: hex0)
    let data1 = try Data(hex: hex1)
    return (BigInt(data: data0), BigInt(data: data1))
}

private extension HashToCurveG1Tests {
    
    func doTestG2(
        name: String,
        reverseVectorOrder: Bool = false
    ) async throws {
        try await doTest(
            name: name,
            reverseVectorOrder: reverseVectorOrder
        ) { _, vector in
           
                
                func fp2(
                    _ keyPath: KeyPath<DecodableElement, String>,
                    in decodableElement: DecodableElement
                ) throws -> Fp2 {
                    let hexConcatenated: String = decodableElement[keyPath: keyPath]
                    let (c0, c1) = try bigInt(hexConcatenated: hexConcatenated)
                    return Fp2(c0: Fp(value: c0), c1: Fp(value: c1))
                }
                
                func pointG2(from decodableElement: DecodableElement) throws -> P2 {
                    let x = try fp2(\.x, in: decodableElement)
                    let y = try fp2(\.y, in: decodableElement)
                    return P2(x: x, y: y)
                }
                
                let Q0 = try pointG2(from: vector.Q0)
                let Q1 = try pointG2(from: vector.Q1)
                let expected = try pointG2(from: vector.P)
                return expected
          
        } functionForOperation: { operation in
            switch operation {
            case .encode:
                fatalError("not supported yet")
            case .hash:
                return {
                    try await P2.hashToCurve(
                        message: $0,
                        hashToFieldConfig: .init(domainSeperationTag: $1)
                    )
                }
            }
        } operationResultToExpected: { (projective: P2) in
            projective
        }
    }
    
    func doTest<Expected: Equatable, OperationResult: Equatable>(
        name: String,
        reverseVectorOrder: Bool = false,
        expectedFromVector: @escaping (Array<HashToCurveTestSuite<Expected>.Vector>.Index, HashToCurveTestSuite<Expected>.Vector) throws -> Expected,
        functionForOperation: @escaping (Operation_) -> (Message, DomainSeperationTag) async throws -> OperationResult,
        operationResultToExpected: @escaping (OperationResult) throws -> Expected
    ) async throws {
        
        try await doTestSuite(
            name: name,
            reverseVectorOrder: reverseVectorOrder
        ) { (suite: HashToCurveTestSuite<Expected>, vector: HashToCurveTestSuite<Expected>.Vector, vectorIndex: Int) in
            print("✨ Starting test vector: #\(vectorIndex) in suite: '\(suite.name)'")
            let message = try vector.message()
            let expected = try expectedFromVector(vectorIndex, vector)
            let function = functionForOperation(suite.operation)
            let operationResult = try await function(message, suite.domainSeparationTag())
            let result = try operationResultToExpected(operationResult)
            XCTAssertEqual(result, expected)
            if result == expected {
                print("✅ passed test vector: #\(vectorIndex) in suite: '\(suite.name)'")
            }
        }
    }
    
    func doTestSuite<Element: Equatable>(
        name: String,
        reverseVectorOrder: Bool = false,
        testVector: @escaping (HashToCurveTestSuite<Element>, HashToCurveTestSuite<Element>.Vector, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: HashToCurveTestSuite<Element>.self,
            reverseVectorOrder: reverseVectorOrder,
            testVectorFunction: testVector
        )
    }
}

struct HashToCurveTestSuite<Element>: CipherSuite, Decodable {
    
    let ciphersuite: String
    let dst: String
    let randomOracle: Bool
    let vectors: [Vector]

    ///{
    ///  "P": {
    ///    "x": ///"0x0141ebfbdca40eb85b87142e130ab689c673cf60f1a3e98d69335266f30d9b8d4ac44c1038e9dcdd5393faf5c41fb78a///,0x05cb8437535e20ecffaef7752baddf98034139c38452458baeefab379ba13dff5bf5dd71b72418717047f5b0f37da03d",
    ///    "y": ///"0x0503921d7f6a12805e72940b963c0cf3471c7b2a524950ca195d11062ee75ec076daf2d4bc358c4b190c0c98064fdd92///,0x12424ac32561493f3fe3c260708a12b7c620e7be00099a974e259ddc7d1f6395c3c811cdd19f1e8dbf3e9ecfdcbab8d6"
    ///  },
    ///  "Q0": {
    ///    "x": ///"0x019ad3fc9c72425a998d7ab1ea0e646a1f6093444fc6965f1cad5a3195a7b1e099c050d57f45e3fa191cc6d75ed7458c///,0x171c88b0b0efb5eb2b88913a9e74fe111a4f68867b59db252ce5868af4d1254bfab77ebde5d61cd1a86fb2fe4a5a1c1d",
    ///    "y": ///"0x0ba10604e62bdd9eeeb4156652066167b72c8d743b050fb4c1016c31b505129374f76e03fa127d6a156213576910fef3///,0x0eb22c7a543d3d376e9716a49b72e79a89c9bfe9feee8533ed931cbb5373dde1fbcd7411d8052e02693654f71e15410a"
    ///  },
    ///  "Q1": {
    ///    "x": ///"0x113d2b9cd4bd98aee53470b27abc658d91b47a78a51584f3d4b950677cfb8a3e99c24222c406128c91296ef6b45608be///,0x13855912321c5cb793e9d1e88f6f8d342d49c0b0dbac613ee9e17e3c0b3c97dfbb5a49cc3fb45102fdbaf65e0efe2632",
    ///    "y": ///"0x0fd3def0b7574a1d801be44fde617162aa2e89da47f464317d9bb5abc3a7071763ce74180883ad7ad9a723a9afafcdca///,0x056f617902b3c0d0f78a9a8cbda43a26b65f602f8786540b9469b060db7b38417915b413ca65f875c130bebfaa59790c"
    ///  },
    ///  "msg": "",
    ///  "u": [
    ///    "0x03dbc2cce174e91ba93cbb08f26b917f98194a2ea08d1cce75b2b9cc9f21689d80bd79b594a613d0a68eb807dfdc1cf8///,0x05a2acec64114845711a54199ea339abd125ba38253b70a92c876df10598bd1986b739cad67961eb94f7076511b3b39a",
    ///    "0x02f99798e8a5acdeed60d7e18e9120521ba1f47ec090984662846bc825de191b5b7641148c0dbc237726a334473eee94///,0x145a81e418d4010cc027a68f14391b30074e89e60ee7a22f87217b2f6eb0c4b94c9115b436e6fa4607e95a98de30a435"
    ///  ]
    ///},
    struct Vector: Decodable {
        let P: DecodableElement
        let Q0: DecodableElement
        let Q1: DecodableElement
        let msg: String
        let u: [String]
        
        func message(line: UInt = #line) throws -> Data {
            try XCTUnwrap(msg.data(using: .utf8), line: line)
        }
    }
}



struct DecodableElement: Decodable {
    let x: String
    let y: String
}

extension HashToCurveTestSuite {
    var operation: Operation_ {
        if randomOracle {
            return .hash
        } else {
            return .encode
        }
    }
    
    func domainSeparationTag(line: UInt = #line) throws -> DomainSeperationTag {
        let data = try XCTUnwrap(dst.data(using: .utf8), line: line)
        return .init(data: data)
    }
}

public enum Operation_: Equatable {
    case hash
    case encode
}

private extension Operation_ {
    var isHash: Bool {
        switch self {
        case .hash: return true
        case .encode: return false
        }
    }
}
