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

final class G1Tests: GroupTest<G1> {
    
    func test_g1_from_xyz_valid_point() {
        XCTAssertNoThrow(
            try G1(
                x: .init(value: BigInt("3924344720014921989021119511230386772731826098545970939506931087307386672210285223838080721449761235230077903044877", radix: 10)!),
                y: .init(value: BigInt("849807144208813628470408553955992794901182511881745746883517188868859266470363575621518219643826028639669002210378", radix: 10)!),
                z: .init(value: BigInt("3930721696149562403635400786075999079293412954676383650049953083395242611527429259758704756726466284064096417462642", radix: 10)!)
            )
        )
    }
    
    func test_g1_throws_error_invalid_point() {
        XCTAssertThrowsError(try G1(
            x: .init(hex: "034a6fce17d489676fb0a38892584cb4720682fe47c6dc2e058811e7ba4454300c078d0d7d8a147a594b8758ef846cca"),
            y: .init(hex: "14e4b429606d02bc3c604c0410e5fc01d6093a00bb3e2bc9395952af0b6a0dbd599a8782a1bea48a5aa4d8e1b1df7caa"),
            z: .init(hex: "1167e903c75541e3413c61dae83b15c9f9ebc12baba015ec01b63196580967dba0798e89451115c8195446528d8bcfca")
        ))
    }
    
}
