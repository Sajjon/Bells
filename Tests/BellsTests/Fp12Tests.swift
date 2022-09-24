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


final class Fp12Tests: FieldTest<Fp12> {
    
}

extension Fp12: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            Self(
                c0: composer.generate(using: Fp6.arbitrary),
                c1: composer.generate(using: Fp6.arbitrary)
            )
        }
    }
}
