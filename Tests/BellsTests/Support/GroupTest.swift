//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
@testable import Bells
import XCTest
import SwiftCheck
import BigInt

class GroupTest<G>: XCTestCase where G: FiniteGroup & Arbitrary {
    /*
    let args = CheckerArguments(
        maxTestCaseSize: 2 // Decreased from 100
    )
    
    func test_point_equality() {
        property("\(G.self) Equality is Reflexive", arguments: args) <- forAll { (g: G) in
            g == g
        }
    }

    func test_point_mul_scalar_by1() {
        property("\(P.self) Point * 1 == Point", arguments: args) <- forAll { (a: P) in
            try a == a.unsafeMultiply(scalar: 1)
        }
    }
    
    func test_point_doubled_3_times_eq_mul_by_8() {
        property("\(P.self) Point * 8 == Point.doubled.doubled.doubled", arguments: args) <- forAll { (a: P) in
            try a.doubled().doubled().doubled() == (a * 8)
        }
    }
    
    func test_point_doubled_is_itself_added_to_itself() {
        property("\(P.self) Point.doubled == Point + Point", arguments: args) <- forAll { (a: P) in
            a.doubled() == (a + a)
        }
    }
    
    func test_p_unsafe_mul_x_eq_mul_x() {
        property("\(P.self) p unsafeMul x eq p mul x", arguments: args) <- forAll { (a: P) in
            exists { (x: BigInt) in
                (try a * x) == (try a.unsafeMultiply(scalar: x))
            }
        }
    }
    
    func test_p_unsafe_mul_largeInt_eq_mul_largeInt() {
        property("\(P.self) p unsafeMul x eq p mul x", arguments: args) <- forAll { (a: P) in
            (try a * 0xffff_ffff_ffff) == (try a.unsafeMultiply(scalar: 0xffff_ffff_ffff))
        }
    }
     */
}

extension FiniteGroup {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            let scalar = BigInt.arbitrary.suchThat { i in i > 0 && i < Curve.order }
            
            // OK to use `unsafeMultiply` since we are in a test...
            let product = try! Self.generator.point.unsafeMultiply(
                scalar: composer.generate(using: scalar)
            )
            return try! Self(point: product)
        }
    }
}

extension G1: Arbitrary {}

extension G2: Arbitrary {}
