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
        
        let a: Fp2 = "1488924004771393321054797166853618474668089414631333405711627789629391903630694737978065425271543178763948256226639*u + 784063022264861764559335808165825052288770346101304131934508881646553551234697082295473567906267937225174620141295"
      
        XCTAssertEqual(try a.sqrt().squared(), a)
        /*


             // b = 5, which is a generator of the p - 1 order
             // multiplicative subgroup
             let b = Fp2 {
                 c0: Fp::from_raw_unchecked([
                     0x6631_0000_0010_5545,
                     0x2114_0040_0eec_000d,
                     0x3fa7_af30_c820_e316,
                     0xc52a_8b8d_6387_695d,
                     0x9fb4_e61d_1e83_eac5,
                     0x005c_b922_afe8_4dc7,
                 ]),
                 c1: Fp::zero(),
             };

             assert_eq!(b.sqrt().unwrap().square(), b);

             // c = 25, which is a generator of the (p - 1) / 2 order
             // multiplicative subgroup
             let c = Fp2 {
                 c0: Fp::from_raw_unchecked([
                     0x44f6_0000_0051_ffae,
                     0x86b8_0141_9948_0043,
                     0xd715_9952_f1f3_794a,
                     0x755d_6e3d_fe1f_fc12,
                     0xd36c_d6db_5547_e905,
                     0x02f8_c8ec_bf18_67bb,
                 ]),
                 c1: Fp::zero(),
             };

             assert_eq!(c.sqrt().unwrap().square(), c);

             // 2155129644831861015726826462986972654175647013268275306775721078997042729172900466542651176384766902407257452753362*u + 2796889544896299244102912275102369318775038861758288697415827248356648685135290329705805931514906495247464901062529
             // is nonsquare.
             assert!(bool::from(
                 Fp2 {
                     c0: Fp::from_raw_unchecked([
                         0xc5fa_1bc8_fd00_d7f6,
                         0x3830_ca45_4606_003b,
                         0x2b28_7f11_04b1_02da,
                         0xa7fb_30f2_8230_f23e,
                         0x339c_db9e_e953_dbf0,
                         0x0d78_ec51_d989_fc57,
                     ]),
                     c1: Fp::from_raw_unchecked([
                         0x27ec_4898_cf87_f613,
                         0x9de1_394e_1abb_05a5,
                         0x0947_f85d_c170_fc14,
                         0x586f_bc69_6b61_14b7,
                         0x2b34_75a4_077d_7169,
                         0x13e1_c895_cc4b_6c22,
                     ])
                 }
                 .sqrt()
                 .is_none()
             ));
         }

        */
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
