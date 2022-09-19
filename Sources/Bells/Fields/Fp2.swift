//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

/// Fp₂ over complex plane
public struct Fp2: Field {
    /// Real part, aka `c0`
    public let real: Fp
    
    /// Imaginary part, aka `c1`
    public let imaginary: Fp
    
    init(real: Fp, imaginary: Fp) {
        self.real = real
        self.imaginary = imaginary
    }
}

public extension Fp2 {
    
    var description: String {
        """
        Real:: \(real),
        Imgry: \(imaginary)
        """
    }
}

public extension Fp2 {
    static let order = Curve.P2
    static let zero = Self(real: .zero, imaginary: .zero)
    static let one = Self(real: .one, imaginary: .zero)
    
    func negated() -> Self {
        .init(real: real.negated(), imaginary: imaginary.negated())
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, +)
    }
    static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, -)
    }
    static func * (lhs: Self, rhs: Self) -> Self {
        // (A+Bi)(C+Di) = (AC−BD) + (AD+BC)i
        let A = lhs.real
        let B = lhs.imaginary
        let C = rhs.real
        let D = rhs.imaginary
        return .init(real: (A*C - B*D), imaginary: (A*D + B*C))
    }
    static func / (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }
    
    static func * (lhs: Self, rhs: BigInt) -> Self {
        op(lhs, rhs, *)
    }
    
    static func / (lhs: Self, rhs: BigInt) -> Self {
        op(lhs, rhs, /)
    }
    
    /// We wish to find the multiplicative inverse of a nonzero
    /// element a + bu in Fp2. We leverage an identity
    ///
    /// (a + bu)(a - bu) = a² + b²
    ///
    /// which holds because u² = -1. This can be rewritten as
    ///
    /// (a + bu)(a - bu)/(a² + b²) = 1
    ///
    /// because a² + b² = 0 has no nonzero solutions for (a, b).
    /// This gives that (a - bu)/(a² + b²) is the inverse
    /// of (a + bu). Importantly, this can be computing using
    /// only a single inversion in Fp.
    func inverted() throws -> Self {
        let a = real.value
        let b = imaginary.value
        let factor = try Fp(value: a * a + b * b).inverted()
        return .init(real: factor * a, imaginary: factor * -b)
    }
    
    func squared() -> Self {
        let c0 = real
        let c1 = imaginary
        let a = c0 + c1
        let b = c0 - c1
        let c = c0 + c0
        return .init(real: a * b, imaginary: c * c1)
    }
    
    func pow(n: BigInt) throws -> Self {
        try powMod(fqp: self, one: .one, n: n)
    }

    
}

func powMod<F: Field>(
    fqp: F,
    one: F,
    n: BigInt
) throws -> F {
    let elm = fqp
    guard n > 0 else { return one }
    guard n > 1 else { return elm }
    var n = n
    var p = one
    var d = elm
    while n > 0 {
        if n != 0 {
            p = p * d
        }
        n >>= 1
        d = try d.squared()
    }
    return p
}

/*
 function powMod_FQP(fqp: any, fqpOne: any, n: bigint) {
     const elm = fqp;
     if (n === 0n) return fqpOne;
     if (n === 1n) return elm;
     let p = fqpOne;
     let d = elm;
     while (n > 0n) {
         if (n & 1n) p = p.multiply(d);
         n >>= 1n;
         d = d.square();
     }
     return p;
 }

 */

private extension Fp2 {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Fp, Fp) -> Fp) -> Self {
        .init(
            real: operation(lhs.real, rhs.real),
            imaginary: operation(lhs.imaginary, rhs.imaginary)
        )
    }
    
    static func op(_ lhs: Self, _ rhs: BigInt, _ operation: (Fp, BigInt) -> Fp) -> Self {
        .init(
            real: operation(lhs.real, rhs),
            imaginary: operation(lhs.imaginary, rhs)
        )
    }
}
