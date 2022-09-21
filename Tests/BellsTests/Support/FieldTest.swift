import XCTest
@testable import Bells
import BigInt
import Security
import Algorithms
import XCTAssertBytesEqual
import SwiftCheck
#if SWIFT_PACKAGE
import FileCheck
#endif

class FieldTest<F: Field & Arbitrary>: XCTestCase {
    
    func test_field_equality() {
        property("\(F.self) Equality is Reflexive") <- forAll { (a: F) in
            a == a
        }
    }
    
    func test_field_inequality() {
        XCTAssert(fileCheckOutput(withPrefixes: ["INEQUALITY"]) {
            // INEQUALITY: *** Passed 100 tests
            // INEQUALITY-NEXT: .
            property("\(F.self) inequality") <- forAll { (a: F) in
                exists { (b: F) in
                    (a != b)
                }
            }
        })
        
    }
    
    func test_field_addition() {
        XCTAssert(fileCheckOutput(withPrefixes: ["ADDITION_COMMUTATIVITY"]) {
            // ADDITION_COMMUTATIVITY: *** Passed 100 tests
            // ADDITION_COMMUTATIVITY-NEXT: .
            property("commutativity") <- forAll { (a: F) in
                exists { (b: F) in
                    (a + b) == (b + a)
                }
            }
        })
        
        XCTAssert(fileCheckOutput(withPrefixes: ["ADDITION_ASSOCIATIVITY"]) {
            // ADDITION_ASSOCIATIVITY: *** Passed 100 tests
            // ADDITION_ASSOCIATIVITY-NEXT: .
            property("associativity") <- forAll { (a: F) in
                exists { (b: F) in
                    exists { (c: F) in
                        (a + (b + c)) == ((a + b) + c)
                    }
                }
            }
        })
        
        
        property("identity") <- forAll { (a: F) in
            (a + F.zero) == a
        }
    }
    
    func test_field_subtraction() {
        
        property("identity") <- forAll { (a: F) in
            (a - F.zero) == a
        }
        
        property("a - a == 0") <- forAll { (a: F) in
            (a - a) == F.zero
        }
    }
    
    
    
    func test_field_zero_divided_eq() {
        property("division zero divided equality") <- forAll { (a: F) in
            !a.isZero ==> {
                (try! F.zero / a) == F.zero
            }
        }
    }
    
    func test_field_division_distributivity() {
        
        XCTAssert(fileCheckOutput(withPrefixes: ["DIVISION_DIST"]) {
            // DIVISION_DIST: *** Passed 100 tests
            // DIVISION_DIST-NEXT: .
            property("division distributivity") <- forAll { (a: F) in
                exists { (b: F) in
                    exists { (c: F) in
                        !c.isZero ==> {
                            (try! (a + b) / c) == (try! (a / c) + (b / c))
                        }
                    }
                }
            }
        })
    }
    
    func test_field_division_and_multiplication_equality() {
        XCTAssert(fileCheckOutput(withPrefixes: ["DIVISION_AND_MULT_EQ"]) {
            // DIVISION_AND_MULT_EQ: *** Passed 100 tests
            // DIVISION_AND_MULT_EQ-NEXT: .
             property("division and multiplication equality") <- forAll { (a: F) in
                 exists { (b: F) in
                     (!b.isZero && (try? b.inverted()) != nil) ==> {
                         (try! (a / b)) == (try! a * b.inverted())
                     }
                 }
             }
        })
    
    }
}
