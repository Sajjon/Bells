//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-03.
//

import Foundation
import XCTest
@testable import Bells
import BigInt

final class HashSignAndVerifyTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // Tested vs README example: https://github.com/paulmillr/noble-bls12-381, for which tests have been added in Noble.
    func test_hash_message_sign_and_verify() async throws {
        let privateKey = try PrivateKey(scalar: .init(hex: "67d53f170b908cabb9eb326c3c337762d59289a8fec79f7bc9254b584b73265c"))
        let messageData = try Data(hex: "64726e3da8")
        
        let publicKey = privateKey.publicKey()
        
        XCTAssertEqual(publicKey.toHex(compress: true), "a7e75af9dd4d868a41ad2f5a5b021d653e31084261724fb40ae2f1b1c31c778d3b9464502d599cf6720723ec5c68b59d")

        let (signature, message) = try await privateKey.sign(hashing: messageData)

        XCTAssertEqual(message.toHex(compress: true), "a699307340f1f399717e7009acb949d800d09bda1be7f239179d2e2fd9096532e5f597b3d736412bd6cd073ca4fe8056038fa6a09f5ef9e47a9c61d869d8c069b487e64a57f701b2e724fa8cce8fce050d850eeb1b4a39195ce71eed0cb5c807")

        XCTAssertEqual(signature.toHex(compress: true), "b22317bfdb10ba592724c27d0cdc51378e5cd94a12cd7e85c895d2a68e8589e8d3c5b3c80f4fe905ef67aa7827617d04110c5c5248f2bb36df97a58c541961ed0f2fcd0760e9de5ae1598f27638dd3ddaebeea08bf313832a57cfdb7f2baaa03")
        
        
        let isValid = await publicKey.isValidSignature(signature, for: message)
        XCTAssertTrue(isValid)
        
        var isValidOther = true
        
        // Other PublicKey
        isValidOther = await PublicKey.other.isValidSignature(signature, for: message)
        XCTAssertFalse(isValidOther)
        
        // Forge signature
        isValidOther = await publicKey.isValidSignature(.forged, for: message)
        XCTAssertFalse(isValidOther)
        
        // Other message
        isValidOther = await publicKey.isValidSignature(signature, for: .other)
        XCTAssertFalse(isValidOther)
        
        // Other PublicKey, Other message (same sig)
        isValidOther = await PublicKey.other.isValidSignature(signature, for: .other)
        XCTAssertFalse(isValidOther)
        
        // Forge signature, Other Message (same pubkey)
        isValidOther = await publicKey.isValidSignature(.forged, for: .other)
        XCTAssertFalse(isValidOther)
        
        // Other PublicKey, Forge signature (same message)
        isValidOther = await PublicKey.other.isValidSignature(.forged, for: message)
        XCTAssertFalse(isValidOther)
    }

    
    func test_sign_with_many() async throws {
        // Sign 1 msg with 3 keys
        let privateKeys = try [
            "18f020b98eb798752a50ed0563b079c125b0db5dd0b1060d1c1b47d4a193e1e4",
            "23eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000000",
            "16ae669f3be7a2121e17d0c68c05a8f3d6bef21ec0f2315f1d7aec12484e4cf5"
        ].map { try PrivateKey(scalar: .init(hex: $0)) }
          
        let message = try await Message(hashing: Data(hex: "64726e3da8"))
        XCTAssertEqual(message.toHex(compress: true), "a699307340f1f399717e7009acb949d800d09bda1be7f239179d2e2fd9096532e5f597b3d736412bd6cd073ca4fe8056038fa6a09f5ef9e47a9c61d869d8c069b487e64a57f701b2e724fa8cce8fce050d850eeb1b4a39195ce71eed0cb5c807")

        
        let publicKeys = privateKeys.map { $0.publicKey() }
        let signatures = try await privateKeys.asyncMap { try await $0.sign(message: message) }
        let aggregatedPublicKey = try PublicKey.aggregate(publicKeys)
        let aggregatedSignature = try Signature.aggregate(signatures)

        let isValid = await aggregatedPublicKey.isValidSignature(aggregatedSignature, for: message)
        XCTAssertTrue(isValid)
        
        XCTAssertEqual(aggregatedPublicKey.toHex(compress: true), "99f1d4ae64167802393b76a3a14719ee449b59a0e5440ee9d8cc27eedbf42d0783430598ada1d8027910d8d8c2511461")
        
        XCTAssertEqual(aggregatedSignature.toHex(compress: true), "8ba8334c1abba0bd490b14bae814d9e674a6f649dfbe72be2e6caf9b882f0a5b5612fc7ff1865c15f1d3b36faae71322063d92170fa2eaed48a3fddcfd5a2a1de29cb05bdd70ac6e7d7d103e913dc187a56aa1d18229d635f6ca6dddfc8d0cff")
        
        
        var isValidOther = true
        
        // Other PublicKey
        isValidOther = await PublicKey.other.isValidSignature(aggregatedSignature, for: message)
        XCTAssertFalse(isValidOther)
        
        // Forge signature
        isValidOther = await aggregatedPublicKey.isValidSignature(.forged, for: message)
        XCTAssertFalse(isValidOther)
        
        // Other message
        isValidOther = await aggregatedPublicKey.isValidSignature(aggregatedSignature, for: .other)
        XCTAssertFalse(isValidOther)
        
        // Other PublicKey, Other message (same sig)
        isValidOther = await PublicKey.other.isValidSignature(aggregatedSignature, for: .other)
        XCTAssertFalse(isValidOther)
        
        // Forge signature, Other Message (same pubkey)
        isValidOther = await aggregatedPublicKey.isValidSignature(.forged, for: .other)
        XCTAssertFalse(isValidOther)
        
        // Other PublicKey, Forge signature (same message)
        isValidOther = await PublicKey.other.isValidSignature(.forged, for: message)
        XCTAssertFalse(isValidOther)
    }
    
    func test_sign_many_messages_with_many_keys() async throws {
        // Sign 3 msg with 3 keys
        let privateKeys = try [
            "18f020b98eb798752a50ed0563b079c125b0db5dd0b1060d1c1b47d4a193e1e4",
            "23eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000000",
            "16ae669f3be7a2121e17d0c68c05a8f3d6bef21ec0f2315f1d7aec12484e4cf5"
        ].map { try PrivateKey(scalar: .init(hex: $0)) }
        
        let messages = try ["d2", "0d98", "05caf3"].map { try Data(hex: $0) }

        let publicKeys = privateKeys.map { $0.publicKey() }
        let signaturesAndMessages = try await privateKeys.enumerated().asyncMap({ i, sk in
            try await sk.sign(hashing: messages[i])
        })
        
//        let aggregatedPublicKey = try PublicKey.aggregate(publicKeys)
        let aggregatedSignature = try Signature.aggregate(signaturesAndMessages.map { $0.signature })
        
//        let isValid = await aggregatedPublicKey.isValidSignature(aggregatedSignature, for: message)
        let isValid = await PublicKey.isValidSignature(
            aggregatedSignature,
            forMessages: signaturesAndMessages.map { $0.message },
            publicKeysOfSigners: publicKeys
        )
        
        
        
        XCTAssertTrue(isValid)
        
//        XCTAssertEqual(aggregatedPublicKey.toHex(compress: true), "99f1d4ae64167802393b76a3a14719ee449b59a0e5440ee9d8cc27eedbf42d0783430598ada1d8027910d8d8c2511461")
//
//        XCTAssertEqual(aggregatedSignature.toHex(compress: true), "8ba8334c1abba0bd490b14bae814d9e674a6f649dfbe72be2e6caf9b882f0a5b5612fc7ff1865c15f1d3b36faae71322063d92170fa2eaed48a3fddcfd5a2a1de29cb05bdd70ac6e7d7d103e913dc187a56aa1d18229d635f6ca6dddfc8d0cff")
        
    }
    
    // Passes after 140 seconds when run with optimizaiton flags on M1.
    func test_sign_vectors() async throws {

        try await doTestSuite(
            name: "SignatureTestVectors"
        ) { suite, vector, vectorIndex in
            guard vectorIndex >= 2 else { return }
            let dst = try vector.dst()
            
            let messageRaw = try vector.message()
            let g1 = try G1(compressedData: vector.g1CompressedData())
            let g2 = try G2(compressedData: vector.g2CompressedData())
//            try XCTAssertEqual(g1, hashToG1(message: message, domainSeperationTag: dst).element)
            let hashed = try await P2.hashToCurve(
                message: messageRaw,
                hashToFieldConfig: .init(domainSeperationTag: dst)
            )
            XCTAssertEqual(
                g2.point,
                hashed
            )
            
            
            let secretKey = try PrivateKey(
                scalar: BigInt.init(vector.secretKeyDecimalString(), radix: 10)!
            )
            let publicKey = try PublicKey(compressedData: vector.publicKeyData())
            XCTAssertEqual(secretKey.publicKey(), publicKey)
           
//            let signature = try secretKey.sign(
//                message: message,
//                domainSeperationTag: dst
//            )
            let message = Message(groupElement: g2)
            let signature = try await secretKey.sign(message: message)
            
            try XCTAssertEqual(signature.toData(compress: true), vector.signatureData())
            
            // VERIFY
//            let isSignatureValid = try await signature.verify(
//                publicKey: publicKey,
//                message: message,
//                domainSeperationTag: dst
//            )
            let isSignatureValid = await publicKey.isValidSignature(signature, for: message)
            
            XCTAssertTrue(isSignatureValid)
            
            var isValidOther = true
            // Other PublicKey
            isValidOther = await PublicKey.other.isValidSignature(signature, for: message)
            XCTAssertFalse(isValidOther)
            
            // Forge signature
            isValidOther = await publicKey.isValidSignature(.forged, for: message)
            XCTAssertFalse(isValidOther)
            
            // Other message
            isValidOther = await publicKey.isValidSignature(signature, for: .other)
            XCTAssertFalse(isValidOther)
            
            // Other PublicKey, Other message (same sig)
            isValidOther = await PublicKey.other.isValidSignature(signature, for: .other)
            XCTAssertFalse(isValidOther)
            
            // Forge signature, Other Message (same pubkey)
            isValidOther = await publicKey.isValidSignature(.forged, for: .other)
            XCTAssertFalse(isValidOther)
            
            // Other PublicKey, Forge signature (same message)
            isValidOther = await PublicKey.other.isValidSignature(.forged, for: message)
            XCTAssertFalse(isValidOther)
        }
    }
}

private extension Signature {
    static let forged = try! Self.init(groupElement: G2(hex: "b2cc74bc9f089ed9764bbceac5edba416bef5e73701288977b9cac1ccb6964269d4ebf78b4e8aa7792ba09d3e49c8e6a1351bdf582971f796bbaf6320e81251c9d28f674d720cca07ed14596b96697cf18238e0e03ebd7fc1353d885a39407e0")
    )
}

private extension Message {
    static let other = try! Self.init(groupElement: G2(hex: "aa4edef9c1ed7f729f520e47730a124fd70662a904ba1074728114d1031e1572c6c886f6b57ec72a6178288c47c335771638533957d540a9d2370f17cc7ed5863bc0b995b8825e0ee1ea1e1e4d00dbae81f14b0bf3611b78c952aacab827a053")
    )
}

private extension PublicKey {
    static let other: Self = try! PrivateKey(scalar: 237).publicKey()
}



private extension HashSignAndVerifyTest {
    
    func doTestSuite(
        name: String,
        reverseVectorOrder: Bool = false,
        testVector: @escaping (SignTestSuite, SignTestSuite.Test, Int) async throws -> Void,
        line: UInt = #line
    ) async throws {
        try await doTestJSONFixture(
            name: name,
            decodeAs: SignTestSuite.self,
            reverseVectorOrder: reverseVectorOrder,
            testVectorFunction: testVector
        )
    }
}


struct SignTestSuite: TestSuite, Decodable {
    
    public var name: String { "SignTests" }
    public let cases: [Test]
    public var tests: [Test] { cases }

    struct Test: Decodable {
        let Msg: String
        let Ciphersuite: String
        let G1Compressed: String
        let G2Compressed: String
        let BLSPrivKey: String
        let BLSPubKey: String
        let BLSSigG2: String
        
        func message(line: UInt = #line) throws -> Data {
            try XCTUnwrap(Msg.data(using: .utf8), line: line)
        }
        func dst(line: UInt = #line) throws -> DomainSeperationTag {
            let data = try XCTUnwrap(Ciphersuite.data(using: .utf8), line: line)
            return DomainSeperationTag(data: data)
        }
        func secretKeyDecimalString() throws -> String {
            BLSPrivKey
        }
        
        func signatureData(line: UInt = #line) throws -> Data {
            let base64Encoded = try XCTUnwrap(BLSSigG2, line: line)
            return try XCTUnwrap(Data(base64Encoded: base64Encoded), line: line)
        }
        
        func publicKeyData(line: UInt = #line) throws -> Data {
            let base64Encoded = try XCTUnwrap(BLSPubKey, line: line)
            return try XCTUnwrap(Data(base64Encoded: base64Encoded), line: line)
        }
        
        func g1CompressedData(line: UInt = #line) throws -> Data {
            let base64Encoded = try XCTUnwrap(G1Compressed, line: line)
            return try XCTUnwrap(Data(base64Encoded: base64Encoded), line: line)
        }
        
        func g2CompressedData(line: UInt = #line) throws -> Data {
            let base64Encoded = try XCTUnwrap(G2Compressed, line: line)
            return try XCTUnwrap(Data(base64Encoded: base64Encoded), line: line)
        }
    }
}

