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


extension BigInt {
    init(hex: String) {
        self.init(hex, radix: 16)!
    }
}
extension Fp {
    init(hex: String) {
        self.init(value: .init(hex: hex))
    }
}
extension Fp2 {
    init(c0 c0Hex: String, c1 c1Hex: String) {
        self.init(real: .init(hex: c0Hex), imaginary: .init(hex: c1Hex))
    }
}

final class Fp2Tests: FiniteFieldTest<Fp> {
    
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
    
    func test_frobenius() throws {
        let a = Fp2(
            c0: "00f8d295b2ded9dcccc649c4b9532bf3b966ce3bc2108b138b1a52e0a90f59ed11e59ea221a3b6d22d0078036923ffc7",
            c1: "012d1137b8a6a8374e464dea5bcfd41eb3f8afc0ee248cadbe203411c66fb3a5946ae52d684fa7ed977df6efcdaee0db"
        )
        
        let b = a.frobeniusMap(power: 0)
        XCTAssertEqual(a, b)
        
        let c = b.frobeniusMap(power: 1)
        XCTAssertEqual(
            c,
            Fp2(
                real: b.real,
                imaginary: .init(value: BigInt("18d400b280d93e62fcd559cbe77bd8b8b07e9bc405608611a9109e8f3041427e8a411ad149045812228109103250c9d0", radix: 16)!)
            )
        )
        
        let d = c.frobeniusMap(power: 1)
        XCTAssertEqual(d, a)
        
        XCTAssertEqual(d.frobeniusMap(power: 2), d)
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
