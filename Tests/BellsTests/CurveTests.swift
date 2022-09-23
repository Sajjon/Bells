//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-22.
//

import Foundation
import XCTest
import Bells

final class CurveTests: XCTestCase {
    
    /// This test will probably fail if run on a 32 bit OS, but who runs 32 bit nowadays?
    func test_expected_words_of_P() {
        let uint64Modulos = Curve.P.words
        let fail = "This test probably failed since you are running it on a non 64-bit OS, e.g. 32 bit OS. Please raise an issue on Github (github.com/sajjon/Bells)"
        XCTAssertEqual(uint64Modulos[0], 0xb9fe_ffff_ffff_aaab, fail)
        XCTAssertEqual(uint64Modulos[1], 0x1eab_fffe_b153_ffff, fail)
        XCTAssertEqual(uint64Modulos[2], 0x6730_d2a0_f6b0_f624, fail)
        XCTAssertEqual(uint64Modulos[3], 0x6477_4b84_f385_12bf, fail)
        XCTAssertEqual(uint64Modulos[4], 0x4b1b_a7b6_434b_acd7, fail)
        XCTAssertEqual(uint64Modulos[5], 0x1a01_11ea_397f_e69a, fail)
    }
}
