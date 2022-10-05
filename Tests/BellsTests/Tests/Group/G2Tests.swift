//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import XCTest
@testable import Bells
import BigInt


final class G2Tests: GroupTest<G2> {
    
    func test_g2_from_uncompressed_data_zero() throws {
        let g2 = try G2(hex: "400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(g2, .zero)
    }
    func test_g2_from_uncompressed_data_non_zero() throws {
        let g2 = try G2(hex: "13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb80606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801")
        XCTAssertEqual(g2.x, .init(c0: Fp(hex: "024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8"), c1: Fp(hex: "13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e")))
        
        XCTAssertEqual(g2.y, .init(c0: Fp(hex: "0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801"), c1: Fp(hex: "0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be")))
    }
    
    func test_g2_from_compressed_data_non_zero() throws {
        XCTAssertNoThrow(try G2(hex: "b2cc74bc9f089ed9764bbceac5edba416bef5e73701288977b9cac1ccb6964269d4ebf78b4e8aa7792ba09d3e49c8e6a1351bdf582971f796bbaf6320e81251c9d28f674d720cca07ed14596b96697cf18238e0e03ebd7fc1353d885a39407e0")
        )
        
    }
    
    func test_g2_from_compressed_data_zero() throws {
        XCTAssertEqual(try G2(hex: "c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"), .zero)
    }
    
    func test_g2_from_compressed_data_non_zero2() throws {
        let exp = try G2.identity + G2.generator
        XCTAssertEqual(try G2(hex: "93E02B6052719F607DACD3A088274F65596BD0D09920B61AB5DA61BBDC7F5049334CF11213945D57E5AC7D055D042B7E024AA2B2F08F0A91260805272DC51051C6E47AD4FA403B02B4510B647AE3D1770BAC0326A805BBEFD48056C8C121BDB8".lowercased()), exp)
        XCTAssertEqual(exp.toData(compress: true).hex(), "93E02B6052719F607DACD3A088274F65596BD0D09920B61AB5DA61BBDC7F5049334CF11213945D57E5AC7D055D042B7E024AA2B2F08F0A91260805272DC51051C6E47AD4FA403B02B4510B647AE3D1770BAC0326A805BBEFD48056C8C121BDB8".lowercased())
    }
    
    func test_g2_gen_x3() throws {
        let g2 = try G2(compressedData: Data(hex: "aa4edef9c1ed7f729f520e47730a124fd70662a904ba1074728114d1031e1572c6c886f6b57ec72a6178288c47c335771638533957d540a9d2370f17cc7ed5863bc0b995b8825e0ee1ea1e1e4d00dbae81f14b0bf3611b78c952aacab827a053"))
        
        XCTAssertEqual(g2.x.c0.toHexString(), "1638533957d540a9d2370f17cc7ed5863bc0b995b8825e0ee1ea1e1e4d00dbae81f14b0bf3611b78c952aacab827a053")
        XCTAssertEqual(g2.x.c1.toHexString(), "0a4edef9c1ed7f729f520e47730a124fd70662a904ba1074728114d1031e1572c6c886f6b57ec72a6178288c47c33577")
        XCTAssertEqual(g2.y.c0.toHexString(), "0468fb440d82b0630aeb8dca2b5256789a66da69bf91009cbfe6bd221e47aa8ae88dece9764bf3bd999d95d71e4c9899")
        XCTAssertEqual(g2.y.c1.toHexString(), "0f6d4552fa65dd2638b361543f887136a43253d9c66c411697003f7a13c308f5422e1aa0a59c8967acdefd8b6e36ccf3")
        XCTAssertEqual(g2.z.c0.toHexString(), "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001")
        XCTAssertEqual(g2.z.c1.toHexString(), "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
      
        
        XCTAssertEqual(g2, try G2.identity + G2.generator + G2.generator)
    }
    
    func test_g2_generator() {
        XCTAssertEqual(G2.generator.x.c0.toHexString(), "024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8")
        
        XCTAssertEqual(G2.generator.x.c1.toHexString(), "13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e")
        
        XCTAssertEqual(G2.generator.y.c0.toHexString(), "0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801")
        XCTAssertEqual(G2.generator.y.c1.toHexString(), "0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be")
        
        XCTAssertEqual(G2.generator.z.c0.toHexString(), "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001")
        XCTAssertEqual(G2.generator.z.c1.toHexString(), "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    }
    
    func test_g2_uncompressed() async throws {

        try await elementOnCurveTest(
            name: "g2_uncompressed_valid_test_vectors",
            groupType: G2.self,
            serialize: { $0.toData(compress: false) },
            deserialize: G2.init(uncompressedData:)
        )
    }

    func test_g2_compressed() async throws {

        try await elementOnCurveTest(
            name: "g2_compressed_valid_test_vectors",
            groupType: G2.self,
            serialize: { $0.toData(compress: true) },
            deserialize: G2.init(compressedData:)
        )
    }
}
