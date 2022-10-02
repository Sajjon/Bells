//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-01.
//

import Foundation
import XCTest
@testable import Bells
import XCTAssertBytesEqual
import BigInt

extension Int {
    static let hexCharsPerByte = 2
}
extension BLS {
    static let publicKeyUncompressedHexCount = publicKeyUncompressedByteCount * .hexCharsPerByte
}

extension ProjectivePoint {
    init(hex: String) throws {
        try self.init(bytes: Data(hex: hex))
    }
}

@MainActor
final class SerializationTests: XCTestCase {

    func test_construct_P1_uncompressed_raw_bytes_zero() throws {
        let g1 = try P1(hex: "400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertTrue(g1.isZero)
        XCTAssertEqual(g1, P1.zero)
        XCTAssertEqual(g1.x, P1.zero.x)
        XCTAssertEqual(g1.y, P1.zero.y)
        XCTAssertEqual(g1.z, P1.zero.z)
    }
    
    func test_construct_P1_compressed_raw_bytes_zero() throws {
        let g1 = try P1(hex: "c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertTrue(g1.isZero)
        XCTAssertEqual(g1, P1.zero)
        XCTAssertEqual(g1.x, P1.zero.x)
        XCTAssertEqual(g1.y, P1.zero.y)
        XCTAssertEqual(g1.z, P1.zero.z)
    }
    
    func test_construct_P1_uncompressed_raw_bytes() throws {
        let g1 = try P1(hex:
             "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"
           )
        
        XCTAssertNoThrow(try g1.assertValidity())
        let x = Fp(value:
             BigInt(
                "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb", radix: 16)!
                   )
        let y = Fp(value:
             BigInt(
                "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1", radix: 16)!
           )

        XCTAssertEqual(g1.x, x)
        XCTAssertEqual(g1.y, y)

            
        XCTAssertEqual(g1.toData(compress: false).hex(), "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1")
        
        
    XCTAssertEqual(g1.toData(compress: true).hex(), "97f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb")
        let deserializedFromCompressed = try P1(hex: "97f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb")
        XCTAssertEqual(deserializedFromCompressed, g1)
    }
    
    
    
    func test_g1_uncompressed() async throws {
        
        try await elementOnCurveTest(
            name: "g1_uncompressed_valid_test_vectors",
            projectiveType: P1.self,
            serialize: { $0.toData(compress: false) },
            deserialize: P1.init(bytes:)
        )
    }
    
    func test_g1_compressed() async throws {
        
        try await elementOnCurveTest(
            name: "g1_compressed_valid_test_vectors",
            projectiveType: P1.self,
            serialize: { $0.toData(compress: true) },
            deserialize: P1.init(bytes:)
        )
    }
}

extension SerializationTests {
    
    @MainActor
    func elementOnCurveTest<Projective>(
        name: String,
        projectiveType: Projective.Type,
        serialize: @escaping (Projective) throws -> Data,
        deserialize: @escaping (Data) throws -> Projective,
        line: UInt = #line
    ) async throws where Projective: ProjectivePoint, Projective.Affine: Equatable {
        try await doTestDATFixture(name: name, line: line) { suiteData in
            var e = Projective.identity
            var bytesLeftToParse = suiteData
            for _ in 0..<1000 {
                defer { e += .generator }
                let serializedBytes = try serialize(e)
                let byteCount = serializedBytes.count
                
                let bytesToDeserialize = bytesLeftToParse.removingFirst(byteCount)
                do {
                    
                let pointDeserialized = try deserialize(bytesToDeserialize)

                if serializedBytes != bytesToDeserialize {
                    fatalError("serializedBytes: \(serializedBytes.hex()) != bytesToDeserialize: \(bytesToDeserialize.hex())")
                }
//                XCTAssertEqual(serializedBytes, bytesToDeserialize)
                XCTAssertEqual(e, pointDeserialized)
                } catch {
                    print("derialization error: \(error), bytesToDeserialize: \(bytesToDeserialize.hex()), serializedBytes: \(serializedBytes.hex())")
                    print("\n")
                }
            }
            XCTAssertEqual(bytesLeftToParse.count, 0, line: line)
        }
    }
}

extension RangeReplaceableCollection {
    mutating func removingFirst(_ length: Int) -> Self.SubSequence {
        let removed = prefix(length)
        removeFirst(length)
        return removed
    }
}
