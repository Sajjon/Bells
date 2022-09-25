//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-20.
//

import Foundation
@testable import Bells
import BigInt

extension Fp {
    init(words: [BigInt.Word]) {
        self.init(value: .init(words: words))
    }
}

extension Fp2 {
    init(
        c0: [BigInt.Word],
        c1: [BigInt.Word]
    ) {
        self.init(
            c0: .init(words: c0),
            c1: .init(words: c1)
        )
    }
    
    /// Initialization of Fp using a string on format `<IMG>*u + <c0>`
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
    ///        c0: [
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
        self.init(c0: real, c1: img)
        
    }
    static let complexStringSeparator = "+"
    
}
extension Fp2: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(value)
    }
}

extension BigInt {
    init(hex: String) {
        var hex = hex
        if hex.starts(with: "0x") {
            hex = String(hex.dropFirst(2))
        }
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
        self.init(c0: Fp(hex: c0Hex), c1: Fp(hex: c1Hex))
    }
}
