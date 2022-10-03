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
    
    // Tested vs README example: https://github.com/paulmillr/noble-bls12-381, for which tests have been added in Noble.
    func test_hash_message_sign_and_verify() async throws {
        let privateKey = try PrivateKey(scalar: .init(hex: "67d53f170b908cabb9eb326c3c337762d59289a8fec79f7bc9254b584b73265c"))
        let messageData = try Data(hex: "64726e3da8")
        
        let publicKey = privateKey.publicKey()
        
        XCTAssertEqual(publicKey.point.toData(compress: true).hex(), "a7e75af9dd4d868a41ad2f5a5b021d653e31084261724fb40ae2f1b1c31c778d3b9464502d599cf6720723ec5c68b59d")

        let (signature, message) = try await privateKey.sign(hashing: messageData)

        XCTAssertEqual(message.toData(compress: true).hex(), "a699307340f1f399717e7009acb949d800d09bda1be7f239179d2e2fd9096532e5f597b3d736412bd6cd073ca4fe8056038fa6a09f5ef9e47a9c61d869d8c069b487e64a57f701b2e724fa8cce8fce050d850eeb1b4a39195ce71eed0cb5c807")

        XCTAssertEqual(signature.toData(compress: true).hex(), "b22317bfdb10ba592724c27d0cdc51378e5cd94a12cd7e85c895d2a68e8589e8d3c5b3c80f4fe905ef67aa7827617d04110c5c5248f2bb36df97a58c541961ed0f2fcd0760e9de5ae1598f27638dd3ddaebeea08bf313832a57cfdb7f2baaa03")
        
        
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
