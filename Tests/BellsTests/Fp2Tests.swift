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

extension Fp {
    init(words: [BigInt.Word]) {
        self.init(value: .init(words: words))
    }
}

extension Fp2 {
    init(
        real: [BigInt.Word],
        img: [BigInt.Word]
    ) {
        self.init(
            real: .init(words: real),
            imaginary: .init(words: img)
        )
    }
    init(
        real: BigInt,
        img: BigInt
    ) {
        self.init(
            real: .init(value: real),
            imaginary: .init(value: img)
        )
    }
    
    /// Initialization of Fp using a string on format `<IMG>*u + <REAL>`
    /// where <REAL> and <IMG> are decimal strings.
    ///
    /// Example:
    ///
    /// `"1488924004771393321054797166853618474668089414631333405711627789629391903630694737978065425271543178763948256226639*u + 784063022264861764559335808165825052288770346101304131934508881646553551234697082295473567906267937225174620141295"`
    ///
    /// Line breaks and spaces are trimmed, so this string is also ok:
    /// """
    /// 1488924004771393321054797166853618474668089414631333405711627789629391903630694737978065425271543178763948256226639*u
    /// +
    /// 784063022264861764559335808165825052288770346101304131934508881646553551234697082295473567906267937225174620141295
    /// """
    ///
    /// Which should be equal:
    ///
    ///     Fp2(
    ///        real: [
    ///           0x2bee_d146_27d7_f9e9,
    ///           0xb661_4e06_660e_5dce,
    ///           0x06c4_cc7c_2f91_d42c,
    ///           0x996d_7847_4b7a_63cc,
    ///           0xebae_bc4c_820d_574e,
    ///           0x1886_5e12_d93f_d845,
    ///       ],
    ///       img: [
    ///           0x7d82_8664_baf4_f566,
    ///           0xd17e_6639_96ec_7339,
    ///           0x679e_ad55_cb40_78d0,
    ///           0xfe3b_2260_e001_ec28,
    ///           0x3059_93d0_43d9_1b68,
    ///           0x0626_f03c_0489_b72d,
    ///       ]
    ///      )
    ///
    init(_ complex: String) throws {
        let components = complex.components(separatedBy: Self.complexStringSeparator)
        guard components.count == 2 else {
            struct IncorrectNumberOfComponents: Error {}
            throw IncorrectNumberOfComponents()
        }
        var imaginaryString = components[0].trimmingCharacters(in: .whitespaces)
        if imaginaryString.hasSuffix("*u") {
            imaginaryString.removeLast(2)
        }
        let realString = components[1].trimmingCharacters(in: .whitespaces)
        guard
            let img = BigInt(imaginaryString, radix: 10),
            let real = BigInt(realString, radix: 10)
        else {
            struct FailedToParseIntsFromDecimalString: Error {}
            throw FailedToParseIntsFromDecimalString()
        }
        self.init(real: .init(value: real), imaginary: .init(value: img))
        
    }
    static let complexStringSeparator = "+"
    
}
extension Fp2: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(value)
    }
}

final class Fp2Tests: FieldTests<Fp> {
    
    // Test from: https://github.com/zkcrypto/bls12_381/blob/080eaa74ec0e394377caa1ba302c8c121df08b07/src/fp2.rs#L674-L754
    func test_sqrt() throws {
        
        func doTestSqrtSquared(of fp: Fp2) throws {
            XCTAssertEqual(try fp.sqrt().squared(), fp)
        }
        
        try doTestSqrtSquared(of: "1488924004771393321054797166853618474668089414631333405711627789629391903630694737978065425271543178763948256226639*u + 784063022264861764559335808165825052288770346101304131934508881646553551234697082295473567906267937225174620141295")
        
        
        //  b = 5 , generator of the p-1 order multiplicative subgroup
        try doTestSqrtSquared(of: "0*u + 1367714067195338330005789785234579356639813143898609672616051936515282693167588605474094216909910046701175380147690")
      
        // c = 25, which is a generator of the (p - 1) / 2 order multiplicative subgroup
        try doTestSqrtSquared(of: "0*u + 25")
        
        XCTAssertThrowsError(try Fp2("2155129644831861015726826462986972654175647013268275306775721078997042729172900466542651176384766902407257452753362*u + 2796889544896299244102912275102369318775038861758288697415827248356648685135290329705805931514906495247464901062529").sqrt())
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
