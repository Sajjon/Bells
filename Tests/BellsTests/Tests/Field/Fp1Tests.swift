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
final class FpTests: FieldTest<Fp> {
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
    
    func test_multiplication_known_product() {
        let s = Fp(hex: "08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a5888ae40caa532946c5e7e1")
        let ss = s * s
        XCTAssertEqual(ss.toHexString(), "11bd4610bd54f31efd43b2875b577dfb5298de4a4f230c47a74b117fb392ca098259932bbd672d9ebb861bb35b17939f")
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
