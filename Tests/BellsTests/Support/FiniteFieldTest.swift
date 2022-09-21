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

class FiniteFieldTest<F: FiniteField & Arbitrary>: FieldTest<F> {
    func test_field_negated_equality() {
        XCTAssert(fileCheckOutput(withPrefixes: ["NEGATED_EQUALITY"]) {
            // NEGATED_EQUALITY: *** Passed 100 tests
            // NEGATED_EQUALITY-NEXT: .
            property("negated_eq") <- forAll { (a: F) in
                exists { (b: F) in
                    (F.zero - a == a.negated())
                    ^&&^
                    ((a - b) == (a + b.negated()))
                    ^&&^
                    (a - b) == (a + (b * F.one.negated()))
                }
            }
        })
    }
    
    func test_field_negated() {
        property("a.negated == 0-a") <- forAll { (a: F) in
            a.negated() == (F.zero - a)
        }
        property("a.negated == a * 1.negated") <- forAll { (a: F) in
            a.negated() == (a * F.one.negated())
        }
    }
    
    func test_multiplication() {
        XCTAssert(fileCheckOutput(withPrefixes: ["MULTIPLICATION_COMMUTATIVITY"]) {
            // MULTIPLICATION_COMMUTATIVITY: *** Passed 100 tests
            // MULTIPLICATION_COMMUTATIVITY-NEXT: .
            property("commutativity") <- forAll { (a: F) in
                exists { (b: F) in
                    (a * b) == (b * a)
                }
            }
        })
        
        XCTAssert(fileCheckOutput(withPrefixes: ["MULTIPLICATION_ASSOCIATIVITY"]) {
            // MULTIPLICATION_ASSOCIATIVITY: *** Passed 100 tests
            // MULTIPLICATION_ASSOCIATIVITY-NEXT: .
            property("associativity") <- forAll { (a: F) in
                exists { (b: F) in
                    exists { (c: F) in
                        (a * (b * c)) == ((a * b) * c)
                    }
                }
            }
        })
        
        
        XCTAssert(fileCheckOutput(withPrefixes: ["MULTIPLICATION_DISTRIBUTIVITY"]) {
            // MULTIPLICATION_DISTRIBUTIVITY: *** Passed 100 tests
            // MULTIPLICATION_DISTRIBUTIVITY-NEXT: .
            property("distributivity") <- forAll { (a: F) in
                exists { (b: F) in
                    exists { (c: F) in
                        (a * (b + c)) == ((a * b) + (a * c))
                    }
                }
            }
        })
        property("add equality") <- forAll { (a: F) in
            (a * F.zero) == F.zero
            ^&&^
            (a * F.one) == a
        }
    }
    
    func test_field_square() throws {
        property("square equality") <- forAll { (a: F) in
            (try a.squared()) == (a * a)
        }
    }
    
    func test_field_pow_eq() throws {
        property("pow equality") <- forAll { (a: F) in
            (try a.pow(n: 0) == F.one)
            ^&&^
            (try a.pow(n: 1) == a)
            ^&&^
            (try a.pow(n: 2) == (a * a))
            ^&&^
            (try a.pow(n: 3) == (a * a * a))
            
        }
    }
    
    func test_field_div() {
        property("division by one equality") <- forAll { (a: F) in
            (try a / F.one) == a
        }
        
        property("a / a == 1") <- forAll { (a: F) in
            !a.isZero ==> {
                (try! a / a) == F.one
            }
        }
    }
    
}
