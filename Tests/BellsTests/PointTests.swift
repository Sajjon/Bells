//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-26.
//

import Foundation
@testable import Bells
import XCTest
import SwiftCheck

class PointTest<P>: XCTestCase where P: ProjectivePoint & Arbitrary {
    
    func test_point_equality() {
        property("\(P.self) Equality is Reflexive") <- forAll { (a: P) in
            a == a
        }
    }
    
    func test_point_mul_scalar_by1() {
        property("\(P.self) Point * 1 == Point") <- forAll { (a: P) in
            try a == a.unsafeMultiply(scalar: 1)
        }
    }
    
    func test_point_doubled_3_times_eq_mul_by_8() {
        property("\(P.self) Point * 8 == Point.doubled.doubled.doubled") <- forAll { (a: P) in
            try a.doubled().doubled().doubled() == (a * 8)
        }
    }
}

final class PointG1Tests: PointTest<PointG1> {
    
    
    
    func skip_test_point_multiplication_with_5() throws {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"),
            z: .one
        )

        let a5 = try a.unsafeMultiply(scalar: 5)
        XCTAssertEqual(a5.x.toString(radix: 16, pad: true), "01ee86694b38a2513cd24a4648773811645bfc47087f1c758135cd25e871b090ab541a3370f9ade7551308d4fba7dd8b")
        XCTAssertEqual(a5.y.toString(radix: 16, pad: true), "19f31db260c65c64bf01338623dfa71f1c4b9429f19ff8c9c776157d267a44fe6eb83608557ccffef8a31a71e3573d8d")
        XCTAssertEqual(a5.z.toString(radix: 16, pad: true), "0346f0c9f5a5ab5c4454b77bc42d4d63dfead096169aede021098aae8c95e20b8b0425dde1b6a7ed9ee882defee1c6ee")

    }
//
//
//    func test_point_multiplication_with_3() throws {
//        let a = PointG1(
//            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
//            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"),
//            z: .one
//        )
//
//        let a3 = try a.unsafeMultiply(scalar: 3)
//        XCTAssertEqual(a3.x.toString(radix: 16, pad: true), "0c3c926ff79142f05674c562e83ae387c825591a4b3bf3ff805c2811e2692629219fe79966872509e1f922d6b69dd4e6")
//        XCTAssertEqual(a3.y.toString(radix: 16, pad: true), "0cc975875c1d9b3a529a8f0add6dab65da11a7f47219bd1b8167717bdb62e5478447484a2ed9e8c7f0bfc8ad4088f8b9")
//        XCTAssertEqual(a3.z.toString(radix: 16, pad: true), "18a86b9f1311f110046bc73aceb078b73f493280837e79cda1de1c63cbba1358a3068cf775186bbddeef738ae4924b99")
//
//    }
    
    func test_point_multiplication_with_2() throws {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"),
            z: .one
        )
        
        let a2 = try a.unsafeMultiply(scalar: 2)
        XCTAssertEqual(a2.x.toString(radix: 16, pad: true), "05dff4ac6726c6cb9b6d4dac3f33e92c062e48a6104cc52f6e7f23d4350c60bd7803e16723f9f1478a13c2b29f4325ad")
        XCTAssertEqual(a2.y.toString(radix: 16, pad: true), "14e4b429606d02bc3c604c0410e5fc01d6093a00bb3e2bc9395952af0b6a0dbd599a8782a1bea48a2aa4d8e1b1df7ca5")
        XCTAssertEqual(a2.z.toString(radix: 16, pad: true), "0430df56ea4aba6928180e61b1f2cb8f962f5650798fdf279a55bee62edcdb27c04c720ae01952ac770553ef06aadf22")
    
    }
    
    func test_point_is_on_curve_vector1() {
        let a = PointG1(x: .zero, y: .one, z: .zero)
        XCTAssertNoThrow(try a.assertValidity())
    }
    
    
    
//    func test_point_is_on_curve_vector2() {
//        let a = PointG1(
//            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
//            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"),
//            z: .one
//        )
//
//        XCTAssertNoThrow(try a.assertValidity())
//    }
}

extension PointG1: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            Self(
                x: composer.generate(using: Fp.arbitrary),
                y: composer.generate(using: Fp.arbitrary),
                z: composer.generate(using: Fp.arbitrary)
            )
        }
    }
}
