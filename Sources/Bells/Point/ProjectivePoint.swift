//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation
import BigInt

// MARK: ProjectivePoint

/// A projective point over some *finite* **field** `F`, has three components
/// x, y and z. It is faster to work with projective points than affine, but it can be
/// converted into affine and back into projective from affine.
///
/// When mapping into affine point we multiply the X and Y respectively
/// with the inverse of `Z`. `Xa=Xp/Zp, Ya=Yp/Zp`
public protocol ProjectivePoint<F>:
    CustomToStringConvertible,
    SignedNumeric_,
    ThrowingMultipliableByScalarArtithmetic,
    AdditiveArithmetic,
    Equatable
{
    /// The finite field of which x, y, z are all elements.
    associatedtype F: FiniteField
    
    /// Intended for internal use, used to increase performance.
    var __storageForPrecomputes: [Int: [Self]] { get set }
    
    /// Checks if this point is indeed on the curve.
    func isOnCurve() -> Bool
    
    /// X component, element of the finite field `F`.
    var x: F { get }
    
    /// Y component, element of the finite field `F`.
    var y: F { get }
    
    /// Z component, element of the finite field `F`.
    var z: F { get }
    
    /// Canonocal initializer.
    init(x: F, y: F, z: F)
    
    /// Converts an affine point into this projective point.
    init(affine: AffinePoint<F>)
   
    /// Deserialize a point from data (bytes).
    init(bytes: some ContiguousBytes) throws
    
    /// The generator point of a group this projective point is an element of.
    static var generator: Self { get }
    static var zero: Self { get }
    
    /// Checks if this element is the `zero` element.
    ///
    /// Default implementation provided.
    var isZero: Bool { get }
    
    /// Efficient multiplication by scalar 2.
    ///
    /// Default implementation provided.
    func doubled() -> Self
    
    /// Converts Projective point to default (x, y) coordinates.
    /// Can accept precomputed Z^-1 - for example, from invertBatch.
    ///
    /// Default implementation provided.
    func toAffine(invertedZ: F?) throws -> AffinePoint<F>
    
    /// Serialize point into data (bytes). Might be on compressed form.
    func toData(compress: Bool) -> Data
    
    /// String representation of this point.
    ///
    /// Default implementation provided.
    func toString(radix: Int, pad: Bool) -> String

}

public extension ProjectivePoint {
    mutating func double() {
        self = self.doubled()
    }
}

// MARK: Debugging
public extension ProjectivePoint {
    func toString(radix: Int = 16, pad: Bool = false) -> String {
        """
        \(Self.self)(
            x: \(x.toString(radix: radix, pad: pad)),
            y: \(y.toString(radix: radix, pad: pad)),
            z: \(z.toString(radix: radix, pad: pad))
        )
        """
    }
    
    var description: String {
        toDecimalString(pad: false)
    }
    
    func toDecimalString(pad: Bool = false) -> String {
        toString(radix: 10, pad: pad)
    }
    
    func toHexString(pad: Bool = true) -> String {
        toString(radix: 16, pad: pad)
    }
    
    var debugDescription: String {
        toHexString(pad: true)
    }
}

public extension ProjectivePoint {
    var isZero: Bool { z.isZero }
    
    static var zero: Self {
        .init(
            x: .one, y: .one, z: .zero
        )
    }
    
    static func == (lhs: Self, rhs: some ProjectivePoint<F>) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
    func isEqual(to rhs: some ProjectivePoint<F>) -> Bool {
        let a = self
        let b = rhs
        let xEquals = (a.x * b.z) == (b.x * a.z)
        let yEquals = (a.y * b.z) == (b.y * a.z)
        let isEqual = xEquals && yEquals
        return isEqual
    }
    
    func negated() -> Self {
        Self.init(x: x, y: y.negated(), z: z)
    }
    
    init(affine: AffinePoint<F>) {
        self.init(x: affine.x, y: affine.y, z: .one)
    }
    
    /// Converts Projective point to default (x, y) coordinates.
    /// Can accept precomputed Z^-1 - for example, from invertBatch.
    func toAffine(invertedZ: F? = nil) throws -> AffinePoint<F> {
        let invZ = try invertedZ ?? z.inverted()
        guard !invZ.isZero else {
            throw ProjectivePointError.failedToConvertToAffinePointInverted_Z_cannotBeZero
        }
        return AffinePoint(x: x * invZ, y: y * invZ)
    }
    
    static func toAffineBatch(points: [some ProjectivePoint<F>]) throws -> [AffinePoint<F>] {
        let toInv = try UNTESTED_genInvertBatch(
            fieldType: F.self,
            numbers: points.map { $0.z }
        )
        return try points.enumerated().map({ i, p in try p.toAffine(invertedZ: toInv[i]) })
    }
    
    static func normalizeZ(points: [Self]) throws -> [Self] {
        try toAffineBatch(points: points).map(Self.init(affine:))
    }
    
    /// http://hyperelliptic.org/EFD/g1p/auto-shortw-projective.html#doubling-dbl-1998-cmo-2
    /// `Cost: 6M + 5S + 1*a + 4add + 1*2 + 1*3 + 1*4 + 3*8`.
    func doubled() -> Self {
        let W = x * x * 3
        let S = y * z
        let SS = S * S
        let SSS = SS * S
        let B = x * y * S
        let H = (W * W) - (B * 8)
        let X3 = H * S * 2
        let Y3 = W * (4 * B - H) - 8 * y * y * SS
        let Z3 = SSS * 8
        return Self(x: X3, y: Y3, z: Z3)
    }
    
    /// http://hyperelliptic.org/EFD/g1p/auto-shortw-projective.html#addition-add-1998-cmo-2
    /// Cost: 12M + 2S + 6add + 1*2.
    static func + (lhs: Self, rhs: Self) -> Self {
        let p1 = lhs
        let p2 = rhs
        guard !p1.isZero else { return p2 }
        guard !p2.isZero else { return p1 }
        
        let X1 = p1.x
        let Y1 = p1.y
        let Z1 = p1.z
        
        let X2 = p2.x
        let Y2 = p2.y
        let Z2 = p2.z
        
        let U1 = Y2 * Z1
        let U2 = Y1 * Z2
        let V1 = X2 * Z1
        let V2 = X1 * Z2
        
        if V1 == V2 && U1 == U2 { return p1.doubled() }
        if V1 == V2 && U1 != U2 { return Self.zero }
        
        let U = U1 - U2
        let V = V1 - V2
        let VV = V * V
        let VVV = VV * V
        let V2VV = V2 * VV
        let Z1Z2 = Z1 * Z2
        let A = U * U * Z1Z2 - VVV - V2VV * 2
        let X3 = V * A
        
        let Y3 = (U * (V2VV - A)) - (VVV * U2)
        let Z3 = VVV * Z1Z2
        
        return Self(x: X3, y: Y3, z: Z3)
    }
    
    /// OK for signature verification, UNSAFE for anythyng relating to private key operations.
    func unsafeMultiply(scalar: BigInt) throws -> Self {
        var n = try Self.validate(scalar: scalar)
        var point = Self.zero
        var d = self
        
        while n > 0 {
            if (n & 1) != 0 {
                point += d
            }
            d.double()
            n >>= 1
        }
        return point
    }
    
    // Constant-time multiplication
    static func * (lhs: Self, scalar: BigInt) throws -> Self {
        var n = try validate(scalar: scalar)
        
        var point = zero
        var fake = zero
        var d = lhs
        var bits = Fp.order
        
        while bits > 0 {
            if (n & 1) != 0 {
                point = point + d
            } else {
                fake = fake + d
            }
            d.double()
            n >>= 1
            bits >>= 1
        }
        return point
    }
}

// MARK: Precompute
public extension ProjectivePoint {
    
    mutating func calcMultiplyPrecomputes(w: Int) throws {
        guard __storageForPrecomputes[w] == nil else {
            throw ProjectivePointError.internalErrorPointAlreadyHasPrecomputes
        }
        __storageForPrecomputes[w] = try Self.normalizeZ(
            points: precompute(window: w)
        )
    }
    
    mutating func clearMultiplyPrecomputes() {
        __storageForPrecomputes = [:]
    }
    
    // Constant time multiplication. Uses wNAF.
    func multiplyPrecomputed(scalar: BigInt) throws -> Self {
        try wNAF(n: Self.validate(scalar: scalar))
    }
}

// MARK: Private
private extension ProjectivePoint {
    
    static func UNTESTED_genInvertBatch<F: Field>(fieldType: F.Type, numbers: [F]) throws -> [F] {
        
        var tmp = [F].init(repeating: F.zero, count: numbers.count)
        
        let lastMultiplied: F = numbers.enumerated().reduce(F.one) { acc, enumeratedTuple in
            let (numberIndex, number) = enumeratedTuple
            guard !number.isZero else { return acc }
            tmp[numberIndex] = acc
            return acc * number
        }
        
        let inverted = try lastMultiplied.inverted()
        
        _ = numbers.reversed().enumerated().reduce(inverted) { acc, enumeratedTuple in
            let (numberIndex, number) = enumeratedTuple
            guard !number.isZero else { return acc }
            tmp[numberIndex] = acc * tmp[numberIndex]
            return acc * number
        }
        
        return tmp
    }
    
    
    func wNAF(n: BigInt) -> Self /*, Self)*/ {
        var n = n
        let W: Int
        let precomputes: [Self]
        if let pre = __storageForPrecomputes.first {
            precondition(__storageForPrecomputes.count == 1, "Cyon: unsure about translation from Noble-Bls12-381, it looks like it only supports one key value?")
            W = pre.key
            precomputes = pre.value
        } else {
            W = 1
            precomputes = precompute(window: W)
        }
        var p = Self.zero
        var f = Self.zero
        
        // Split scalar by W bits, last window can be smaller
        let windows = Int(ceil(Double(F.maxBits) / Double(W)))
        // 2^(W-1), since we use wNAF, we only need W-1 bits
        let windowSize = Int(Float.exp2(Float((W-1))))
        
        let mask = BigInt(windowSize) // Create mask with W ones: 0b1111 for W=4 etc.
        let maxNumber = Int(Float.exp2(Float((W)))) // 2 ** W;
        let shiftBy = BigInt(W)
        
        for window in 0..<windows {
            let offset = window * windowSize
            // Extract W bits.
            var wbits = Int(n & mask)
            // Shift number by W bits.
            n >>= shiftBy
            
            // If the bits are bigger than max size, we'll split those.
            // +224 => 256 - 32
            if (wbits > windowSize) {
                wbits -= maxNumber
                n += 1
            }
            
            // Check if we're onto Zero point.
            // Add random point inside current window to f.
            if (wbits == 0) {
                f += (window.isMultiple(of: 2) ? precomputes[offset].negated() : precomputes[offset])
            } else {
                let cached = precomputes[offset + abs(wbits) - 1]
                p += (wbits < 0 ? cached.negated() : cached)
            }
        }
//        return (p, f)
        return p
    }
    
    func precompute(window w: Int) -> [Self] {
        // Split scalar by W bits, last window can be smaller
        let windows = Int(ceil(Double(F.maxBits) / Double(w)))
        // 2^(W-1), since we use wNAF, we only need W-1 bits
        let windowSize = Int(Float.exp2(Float((w-1))))
        
        var points: [Self] = []
        var p = self
        var base = p
        for _ in 0..<windows {
            base = p
            points.append(base)
            for _ in 1..<windowSize {
                base += p
                points.append(base)
            }
            p = base.doubled()
        }
        return points
    }

    static func validate(scalar: BigInt) throws -> BigInt {
        guard scalar > 0 else {
            throw ProjectivePointError.invalidScalarMustBeLargerThanZero
        }
        guard scalar <= Curve.r else {
            throw ProjectivePointError.invalidScalarMustNotBeLargerThanOrder
        }
        // OK!
        return scalar
    }
}

// MARK: Error
public enum ProjectivePointError: String, Swift.Error, Equatable {
    case failedToConvertToAffinePointInverted_Z_cannotBeZero
    case invalidScalarMustBeLargerThanZero
    case invalidScalarMustNotBeLargerThanOrder
    
    case internalErrorPointAlreadyHasPrecomputes
}
