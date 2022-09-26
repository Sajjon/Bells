//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

/// Fp₂ over complex plane
public struct Fp2: FiniteField, CustomDebugStringConvertible {
    /// Real part, aka `c0`
    public let c0: Fp
    
    /// Imaginary part, aka `c1`
    public let c1: Fp
    
    public init(c0: Fp, c1: Fp) {
        self.c0 = c0
        self.c1 = c1
    }
}
private struct BadCount: Error {}
public extension Fp2 {
    init(c0: BigInt, c1: BigInt) {
        self.init(c0: .init(value: c0), c1: .init(value: c1))
    }
    init(real: BigInt, imaginary: BigInt) {
        self.init(c0: real, c1: imaginary)
    }
    init(_ tuple: (BigInt, BigInt)) {
        self.init(c0: tuple.0, c1: tuple.1)
    }
    init(_ tuple: (Fp, Fp)) {
        self.init(c0: tuple.0, c1: tuple.1)
    }
    init(_ collection: some Collection<Fp>) throws {
        guard collection.count == 2 else {
            throw BadCount()
        }
        self.init(c0: collection[collection.startIndex], c1: collection[collection.index(after: collection.startIndex)])
    }
    init(_ collection: some Collection<BigInt>) throws {
        guard collection.count == 2 else {
            throw BadCount()
        }
        self.init(c0: collection[collection.startIndex], c1: collection[collection.index(after: collection.startIndex)])
    }
    var real: BigInt { c0.value }
    var imaginary: BigInt { c1.value }
}

public extension Fp2 {
    
    func toString(radix: Int, pad: Bool) -> String {
        """
        \(Self.self)(
            c0: \(c0.toString(radix: radix, pad: pad)),
            c1: \(c1.toString(radix: radix, pad: pad))
        )
        """
    }
}

public extension Fp2 {
    static let order = Curve.P2
    static let maxBits = Self.order.bitWidthIgnoreSign
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
        // (A+Bi)(C+Di) = (AC−BD) + (AD+BC)i
        let A = lhs.c0
        let B = lhs.c1
        let C = rhs.c0
        let D = rhs.c1
        return .init(c0: (A*C - B*D), c1: (A*D + B*C))
    }
    static func / (lhs: Self, rhs: Self) throws -> Self {
        let inv = try rhs.inverted()
        return lhs * inv
    }
    
    static func * (lhs: Self, rhs: BigInt) -> Self {
        op(lhs, rhs, *)
    }
    
    static func / (lhs: Self, rhs: BigInt) throws -> Self {
        let inv = try Fp(value: rhs).inverted().value
        return lhs * inv
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
        let a = c0.value
        let b = c1.value
        let factor = try Fp(value: a * a + b * b).inverted()
        return .init(c0: factor * a, c1: factor * -b)
    }
    
    func squared() -> Self {
        let a = c0 + c1
        let b = c0 - c1
        let c = c0 + c0
        return .init(c0: a * b, c1: c * c1)
    }
    
    func pow(n: BigInt) throws -> Self {
        try powMod(fqp: self, one: .one, n: n)
    }
    
    // TODO: Optimize this line. It's extremely slow.
    // Speeding this up would boost aggregateSignatures.
    // https://eprint.iacr.org/2012/685.pdf applicable?
    // https://github.com/zkcrypto/bls12_381/blob/080eaa74ec0e394377caa1ba302c8c121df08b07/src/fp2.rs#L250
    // https://github.com/supranational/blst/blob/aae0c7d70b799ac269ff5edf29d8191dbd357876/src/exp2.c#L1
    // Inspired by https://github.com/dalek-cryptography/curve25519-dalek/blob/17698df9d4c834204f83a3574143abacb4fc81a5/src/field.rs#L99
    func sqrt() throws -> Fp2 {
        let candidateSqrt = try pow(n: ((Self.order + 8) / 16))
        let check = try candidateSqrt.squared() / self
        let R = Self.rootsOfUnity
        guard let divisor = [R[0], R[2], R[4], R[6]].first(where: { $0 == check }) else {
            struct NoDivisor: Error {}
            throw NoDivisor()
        }
  
        guard let divisorIndex = R.firstIndex(where: { $0 == divisor }) else {
            struct NoDivisorIndex: Error {}
            throw NoDivisorIndex()
        }
        let root = R[divisorIndex / 2]
        let x1 = try candidateSqrt / root
        let x2 = x1.negated()
        let re1 = x1.c0.value
        let im1 = x1.c1.value
        let re2 = x2.c0.value
        let im2 = x2.c1.value
        if im1 > im2 || (im1 == im2 && re1 > re2) {
            return x1
        }
        return x2
    }

}

internal extension Fp2 {
    /// For `roots of unity`.
    static let rv1 = BigInt("6af0e0437ff400b6831e36d6bd17ffe48395dabc2d3435e77f76e17009241c5ee67992f72ec05f4c81084fbede3cc09", radix: 16)!

}


public extension Fp2 {
    
    /// Eighth roots of unity, used for computing square roots in Fp2.
    /// To verify or re-calculate:
    /// `Array(8).fill(new Fp2([1n, 1n])).map((fp2, k) => fp2.pow(Fp2.ORDER * BigInt(k) / 8n))`
    ///
    ///   `[Fp2](repeating: .(real: .one, imaginary: .one), count: 8).enumerated().map { (fp2, k) in fp2.pow(n: ) }`
    static let rootsOfUnity: [Self] = {
        let tuples: [(BigInt, BigInt)] = [
            (1, 0),
            (rv1, -rv1),
            (0, 1),
            (rv1, rv1),
            (-1, 0),
            (-rv1, rv1),
            (0, -1),
            (-rv1, -rv1)
        ]
        return tuples.map { Self(c0: Fp(value: $0.0), c1: Fp(value: $0.1)) }
    }()
    
    /// Multiply by: `u + 1`
    func mulByNonresidue() -> Self {
        .init(
            c0: c0 - c1,
            c1: c0 + c1
        )
    }
    
    /// Raises to `q**i -th power`
     func frobeniusMap(power: Int) -> Self {
         .init(
            c0: c0,
            c1: c1 * Frobenius.fp2Coefficients[power % Frobenius.fp2Coefficients.count]
        )
     }
    
    func multiplyByB() -> Self {
        let t0 = c0 * 4
        let t1 = c1 * 4
        return .init(c0: t0 - t1, c1: t0 + t1)
    }
}

private extension Fp2 {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Fp, Fp) -> Fp) -> Self {
        .init(
            c0: operation(lhs.c0, rhs.c0),
            c1: operation(lhs.c1, rhs.c1)
        )
    }
    
    static func op(_ lhs: Self, _ rhs: BigInt, _ operation: (Fp, BigInt) -> Fp) -> Self {
        .init(
            c0: operation(lhs.c0, rhs),
            c1: operation(lhs.c1, rhs)
        )
    }
}

func powMod<F: Field>(
    fqp: F,
    one: F,
    n: BigInt
) throws -> F {
    let elm = fqp
    if n == 0 { return one }
    if n == 1 { return elm }
    var n = n
    var p = one
    var d = elm
    while n > 0 {
        if (n & 1) != 0 {
            p = p * d
        }
        n >>= 1
        d = try d.squared()
    }
    return p
}
