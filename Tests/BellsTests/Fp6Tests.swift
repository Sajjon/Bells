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
    func test_aa() throws {
       
        let a = Fp6(
            c0: .init(
                c0: 0x8c0ed57c,
                c1: 0x8c0ed563
            ),
            c1: .init(
                c0: 0x8c0ed562,
                c1: 0x8c0ed561
            ),
            c2: .init(
                c0: 0x8c0ed560,
                c1: 0x8c0ed567
            )
        )
        
        let aa = a * a
      
        XCTAssertEqual(a.squared(), aa)
        
     
        let b = Fp6(
            c0: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed566",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed565"
            ),
            c1: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed564",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56b"
            ),
            c2: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56a",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed569"
            )
        )
        
        let c = Fp6(
            c0: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed568",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56f"
            ),
            c1: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56e",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56d"
            ),
            c2: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56c",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed553"
            )
        )
        XCTAssertEqual(b.squared(), b * b)
        XCTAssertEqual(c.squared(), c * c)
        XCTAssertEqual((a + b) * c.squared(), (c * c * a) + (c * c * b))
//
//        try XCTAssertEqual(
//            a.inverted() * b.inverted(),
//            (a * b).inverted()
//        )
//        
//        try XCTAssertEqual(a.inverted() * a, Fp6.one)
    }


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
