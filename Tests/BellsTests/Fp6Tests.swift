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


final class Fp6Tests: FieldTest<Fp6> {
    

}

extension Fp6: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            Self(
                c0: composer.generate(using: Fp2.arbitrary),
                c1: composer.generate(using: Fp2.arbitrary),
                c2: composer.generate(using: Fp2.arbitrary)
            )
        }
    }
}
