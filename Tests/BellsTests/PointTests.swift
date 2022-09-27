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
import BigInt

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
    
    func test_p_unsafe_mul_x_eq_mul_x() {
        property("\(P.self) p unsafeMul x eq p mul x") <- forAll { (a: P) in
            exists { (x: BigInt) in
                (try a * x) == (try a.unsafeMultiply(scalar: x))
            }
        }
    }
    
    func test_p_unsafe_mul_largeInt_eq_mul_largeInt() {
        property("\(P.self) p unsafeMul x eq p mul x") <- forAll { (a: P) in
            (try a * 0xffff_ffff_ffff) == (try a.unsafeMultiply(scalar: 0xffff_ffff_ffff))
        }
    }
}

final class PointG1Tests: PointTest<PointG1> {
    
    
    
    func test_point_multiplication_with_5() throws {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1"),
            z: .one
        )

        let a5 = try a.unsafeMultiply(scalar: 5)
        XCTAssertEqual(a5.x.toString(radix: 16, pad: true), "01ee86694b38a2513cd24a4648773811645bfc47087f1c758135cd25e871b090ab541a3370f9ade7551308d4fba7dd8b")
        XCTAssertEqual(a5.y.toString(radix: 16, pad: true), "19f31db260c65c64bf01338623dfa71f1c4b9429f19ff8c9c776157d267a44fe6eb83608557ccffef8a31a71e3573d8d")
        XCTAssertEqual(a5.z.toString(radix: 16, pad: true), "0346f0c9f5a5ab5c4454b77bc42d4d63dfead096169aede021098aae8c95e20b8b0425dde1b6a7ed9ee882defee1c6ee")

    }
    
    func test_point_double() throws {
 
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1"),
            z: .one
        )
        let aa = a.doubled()
        XCTAssertEqual(aa.x.toString(radix: 16, pad: true), "02d7746f66839924e53de9082f8a65e4b5274a17c4fedc762f6e22ddddeb324d29871309744a3604cd346417f302c654")
        XCTAssertEqual(aa.y.toString(radix: 16, pad: true), "0dfc7d639436a6c7ab28584eb49eba8e2e9abc707e0fb990217cbcc77d9a6aabd19d7e3e078c51d0cc5f84ea2cee5e50")
        XCTAssertEqual(aa.z.toString(radix: 16, pad: true), "05e2b2e771f02e7353849a3e7f73987cdebd11ee33761af0bea90c4d508d91f91103f8ffeabd9dfde899dc4d19c2a636")
    
    }


    func test_point_addition() throws {
        
  
        let d = PointG1(
            x: .init(hex: "02d7746f66839924e53de9082f8a65e4b5274a17c4fedc762f6e22ddddeb324d29871309744a3604cd346417f302c654"),
            y: .init(hex: "0dfc7d639436a6c7ab28584eb49eba8e2e9abc707e0fb990217cbcc77d9a6aabd19d7e3e078c51d0cc5f84ea2cee5e50"),
            z: .init(hex: "05e2b2e771f02e7353849a3e7f73987cdebd11ee33761af0bea90c4d508d91f91103f8ffeabd9dfde899dc4d19c2a636")
        )
  
        let point = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1"),
            z: .init(hex: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001")
        )
          

          let sum = point + d
        XCTAssertEqual(sum.x.toString(radix: 16, pad: true), "0c3c926ff79142f05674c562e83ae387c825591a4b3bf3ff805c2811e2692629219fe79966872509e1f922d6b69dd4e6")
        XCTAssertEqual(sum.y.toString(radix: 16, pad: true), "0cc975875c1d9b3a529a8f0add6dab65da11a7f47219bd1b8167717bdb62e5478447484a2ed9e8c7f0bfc8ad4088f8b9")
        XCTAssertEqual(sum.z.toString(radix: 16, pad: true), "18a86b9f1311f110046bc73aceb078b73f493280837e79cda1de1c63cbba1358a3068cf775186bbddeef738ae4924b99")
    }
    
    func test_point_multiplication_with_3() throws {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1"),
            z: .one
        )

        let a3 = try a.unsafeMultiply(scalar: 3)
        XCTAssertEqual(a3.x.toString(radix: 16, pad: true), "0c3c926ff79142f05674c562e83ae387c825591a4b3bf3ff805c2811e2692629219fe79966872509e1f922d6b69dd4e6")
        XCTAssertEqual(a3.y.toString(radix: 16, pad: true), "0cc975875c1d9b3a529a8f0add6dab65da11a7f47219bd1b8167717bdb62e5478447484a2ed9e8c7f0bfc8ad4088f8b9")
        XCTAssertEqual(a3.z.toString(radix: 16, pad: true), "18a86b9f1311f110046bc73aceb078b73f493280837e79cda1de1c63cbba1358a3068cf775186bbddeef738ae4924b99")

    }
    
    func test_point_multiplication_with_2() throws {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1"),
            z: .one
        )
        
        let a2 = try a.unsafeMultiply(scalar: 2)
        XCTAssertEqual(a2.x.toString(radix: 16, pad: true), "02d7746f66839924e53de9082f8a65e4b5274a17c4fedc762f6e22ddddeb324d29871309744a3604cd346417f302c654")
        XCTAssertEqual(a2.y.toString(radix: 16, pad: true), "0dfc7d639436a6c7ab28584eb49eba8e2e9abc707e0fb990217cbcc77d9a6aabd19d7e3e078c51d0cc5f84ea2cee5e50")
        XCTAssertEqual(a2.z.toString(radix: 16, pad: true), "05e2b2e771f02e7353849a3e7f73987cdebd11ee33761af0bea90c4d508d91f91103f8ffeabd9dfde899dc4d19c2a636")
    
    }
    
    func test_point_is_on_curve_vector1() {
        let a = PointG1(x: .zero, y: .one, z: .zero)
        XCTAssertNoThrow(try a.assertValidity())
    }
    
    
    
    func test_point_is_on_curve_vector2() {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"),
            z: .one
        )

        XCTAssertNoThrow(try a.assertValidity())
    }
    
    
    func test_point_is_on_curve_vector3() {
        let a = PointG1(
            x: .init(value: BigInt("3924344720014921989021119511230386772731826098545970939506931087307386672210285223838080721449761235230077903044877", radix: 10)!),
            y: .init(value: BigInt("849807144208813628470408553955992794901182511881745746883517188868859266470363575621518219643826028639669002210378", radix: 10)!),
            z: .init(value: BigInt("3930721696149562403635400786075999079293412954676383650049953083395242611527429259758704756726466284064096417462642", radix: 10)!)
        )

        XCTAssertNoThrow(try a.assertValidity())
    }
    
    func test_point_not_on_curve_vector1() {
        let a = PointG1(x: .zero, y: .one, z: .one)
        XCTAssertThrowsError(try a.assertValidity())
    }
    
    func test_point_not_on_curve_vector2() {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6ba"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1"),
            z: .one
        )

        XCTAssertThrowsError(try a.assertValidity())
    }
    
    func test_point_not_on_curve_vector3() {
        let a = PointG1(
            x: .init(hex: "034a6fce17d489676fb0a38892584cb4720682fe47c6dc2e058811e7ba4454300c078d0d7d8a147a594b8758ef846cca"),
            y: .init(hex: "14e4b429606d02bc3c604c0410e5fc01d6093a00bb3e2bc9395952af0b6a0dbd599a8782a1bea48a5aa4d8e1b1df7caa"),
            z: .init(hex: "1167e903c75541e3413c61dae83b15c9f9ebc12baba015ec01b63196580967dba0798e89451115c8195446528d8bcfca")
        )

        XCTAssertThrowsError(try a.assertValidity())
    }
    
    func test_doubled_on_curve_vector1() {
        let a = PointG1(
            x: .init(hex: "17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb"),
            y: .init(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1"),
            z: .one
        )
 
        let doubled = a.doubled()

        XCTAssertEqual(
            doubled,
            .init(
                x: .init(hex: "05dff4ac6726c6cb9b6d4dac3f33e92c062e48a6104cc52f6e7f23d4350c60bd7803e16723f9f1478a13c2b29f4325ad"),
                y: .init(hex: "14e4b429606d02bc3c604c0410e5fc01d6093a00bb3e2bc9395952af0b6a0dbd599a8782a1bea48a2aa4d8e1b1df7ca5"),
                z: .init(hex: "0430df56ea4aba6928180e61b1f2cb8f962f5650798fdf279a55bee62edcdb27c04c720ae01952ac770553ef06aadf22"))
        )
        
        XCTAssertNoThrow(try doubled.assertValidity())
        
        XCTAssertEqual(doubled, a + a)
        XCTAssertEqual(doubled, try a * 2)
    }
    
    func test_doubled_on_curve_vector2() {
        let a = PointG1(
            x: .init(value: BigInt("3924344720014921989021119511230386772731826098545970939506931087307386672210285223838080721449761235230077903044877", radix: 10)!),
            y: .init(value: BigInt("849807144208813628470408553955992794901182511881745746883517188868859266470363575621518219643826028639669002210378", radix: 10)!),
            z: .init(value: BigInt("3930721696149562403635400786075999079293412954676383650049953083395242611527429259758704756726466284064096417462642", radix: 10)!)
        )
 
        let doubled = a.doubled()

        XCTAssertEqual(
            doubled,
            .init(
                x: .init(value: BigInt("1434314241472461137481482360511979492412320309040868403221478633648864894222507584070840774595331376671376457941809", radix: 10)!),
                y: .init(value: BigInt("1327071823197710441072036380447230598536236767385499051709001927612351186086830940857597209332339198024189212158053", radix: 10)!),
                z: .init(value: BigInt("3846649914824545670119444188001834433916103346657636038418442067224470303304147136417575142846208087722533543598904", radix: 10)!)
            )
        )
        
        XCTAssertNoThrow(try doubled.assertValidity())
        
        XCTAssertEqual(doubled, a + a)
        XCTAssertEqual(doubled, try a * 2)
    }
    
    func test_should_not_validate_incorrect_point() {

        let p = PointG1(
            x: .init(value: BigInt("499001545268060011619089734015590154568173930614466321429631711131511181286230338880376679848890024401335766847607", radix: 10)!),
            y: .init(value: BigInt("3934582309586258715640230772291917282844636728991757779640464479794033391537662970190753981664259511166946374555673", radix: 10)!)
        )

        XCTAssertThrowsError(try p.assertValidity())
    }
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
