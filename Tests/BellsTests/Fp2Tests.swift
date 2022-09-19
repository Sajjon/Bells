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

final class Fp2Tests: XCTestCase {
    
    func test_fp2_equality() {
        property("Fp2 Equality is Reflexive") <- forAll { (a: Fp2) in
            a == a
        }
    }
}

extension Fp2: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            Self(
                real: composer.generate(using: Fp.arbitrary),
                imaginary: composer.generate(using: Fp.arbitrary)
            )
        }
    }
}
