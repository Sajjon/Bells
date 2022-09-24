//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

public struct Fp12: Field, CustomDebugStringConvertible {
    public let c0: Fp6
    public let c1: Fp6
}
public extension Fp12 {
    
    init<C>(coeffs: C) where C: Collection, C.Element == BigInt, C.Index == Int {
        precondition(coeffs.count == 16)
        self.init(c0: .init(coeffs: coeffs.prefix(6)), c1: .init(coeffs: coeffs.suffix(6)))
    }
    
}

public extension Fp12 {
    
    var description: String {
        """
        hej
        """
    }
    var debugDescription: String {
        """
        hej
        """
    }
}

public extension Fp12 {
    static let zero = Self(c0: .zero, c1: .zero)
    static let one = Self(c0: .one, c1: .zero)
    
    func negated() -> Self {
        .init(c0: c0.negated(), c1: c1.negated())
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
       op(lhs, rhs, +)
    }
    static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, -)
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        let c0 = lhs.c0
        let c1 = lhs.c1
        let r0 = rhs.c0
        let r1 = rhs.c1
        let t1 = c0 * r0
        let t2 = c1 * r1
        return Self(
            c0: t1 + t2.mulByNonresidue(),
            c1: (c0 + c1) * (r0 + r1) - (t1 + t2)
        )
    }
    
    static func / (lhs: Self, rhs: Self) throws -> Self {
        try lhs * rhs.inverted()
    }
    
    static func * (lhs: Self, rhs: BigInt) -> Self {
        Self.init(c0: lhs.c0 * rhs, c1: lhs.c1 * rhs)
    }
    
    static func / (lhs: Self, rhs: BigInt) throws -> Self {
        let inv = try Fp(value: rhs).inverted().value
        return lhs * inv
    }
    
    
    func inverted() throws -> Self {
        let t = try (c0.squared() - c1.squared().mulByNonresidue()).inverted()
        return Self.init(c0: c0 * t, c1: (c1 * t).negated())
    }
    
    func squared() -> Self {
        let ab = c0 * c1
        return Self(
            c0:  (c1.mulByNonresidue() + c0) * (c0 + c1) - ab - ab.mulByNonresidue(),
            c1: ab + ab
        )
    }
    
    func conjugate() -> Self {
        Self(c0: c0, c1: c1.negated())
    }
    
    func pow(n: BigInt) throws -> Self {
        try powMod(fqp: self, one: .one, n: n)
    }

    /// Raises to `q**i -th power`
    func frobeniusMap(power: Int) -> Self {
        let r0 = self.c0.frobeniusMap(power: power)
        let t = self.c1.frobeniusMap(power: power)
        let c0 = t.c0
        let c1 = t.c1
        let c2 = t.c2
        let coeff = Frobenius.fp12Coefficients[power % Frobenius.fp12Coefficients.count]
        return Self(
            c0: r0,
            c1: .init(
                c0: c0 * coeff,
                c1: c1 * coeff,
                c2: c2 * coeff
            )
        )
    }
}

private extension Fp12 {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Fp6, Fp6) -> Fp6) -> Self {
        .init(
            c0: operation(lhs.c0, rhs.c0),
            c1: operation(lhs.c1, rhs.c1)
        )
    }
}
