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

typealias Fp1Tests = FpTests
final class FpTests: FiniteFieldTest<Fp> {
    func test_field_sqrt() throws {
        let sqr1 = Fp(value: BigInt("300855555557", radix: 10)!)
        let sqrt = try XCTUnwrap(sqr1.sqrt())
        XCTAssertEqual(
            String(sqrt.value, radix: 10),
            "364533921369419647282142659217537440628656909375169620464770009670699095647614890229414882377952296797827799113624"
        )
        XCTAssertNil(Fp(value: BigInt("72057594037927816", radix: 10)!).sqrt())
    }
    
    func test_multiplication_with_larger_than_one() {
        property("add equality") <- forAll { (a: Fp) in
            (a * Fp(value: 2)) == (a + a)
            ^&&^
            (a * Fp(value: 3)) == (a + a + a)
            ^&&^
            (a * Fp(value: 4)) == (a + a + a + a)
        }
    }

}

extension Fp: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            let value = composer.generate(using: BigInt.arbitrary)
            return Self.init(value: value)
        }
    }
}
