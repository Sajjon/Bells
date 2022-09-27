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
    
    func test_point_doubled_is_itself_added_to_itself() {
        property("\(P.self) Point.doubled == Point + Point") <- forAll { (a: P) in
            a.doubled() == (a + a)
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
