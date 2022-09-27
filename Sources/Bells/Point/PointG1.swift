//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//

import Foundation
import BigInt
import RealModule

extension BigInt {
    func serialize(padToLength: Int? = nil, with pad: UInt8 = 0x00) -> Data {
        let data = serialize()
        guard let padToLength, padToLength > data.count else { return data }
        return data + Data([UInt8](
            repeating: pad,
            count: padToLength - data.count
        ))
    }
}

func UNTESTED_genInvertBatch<F: Field>(fieldType: F.Type, numbers: [F]) throws -> [F] {
    
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

public struct AffinePoint<F: Field>: Equatable {
    public let x: F
    public let y: F
    public init(x: F, y: F) {
        self.x = x
        self.y = y
    }
}
public extension AffinePoint {
    func toString(radix: Int = 16, pad: Bool = false) -> String {
        """
        Affine(
            x: \(x.toString(radix: radix, pad: pad)),
            y: \(y.toString(radix: radix, pad: pad)
        )
        """
    }
}

public protocol ProjectivePoint<F> {
    var __storageForPrecomputes: [Int: [Self]] { get set }
    associatedtype F: FiniteField
    var x: F { get }
    var y: F { get }
    var z: F { get }
    init(x: F, y: F, z: F)
    
    static var base: Self { get }
    
    var isZero: Bool { get }
    static func == (lhs: Self, rhs: some ProjectivePoint<F>) -> Bool
    static var zero: Self { get }
    func negated() -> Self
    
    // Converts Projective point to default (x, y) coordinates.
    // Can accept precomputed Z^-1 - for example, from invertBatch.
    func toAffine(invertedZ: F?) throws -> AffinePoint<F>
    func toString(radix: Int, pad: Bool) -> String
    
}

struct InvalidScalar: Error {}
struct PointAlreadyHasPrecomputes: Error {}

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
    
    // Converts Projective point to default (x, y) coordinates.
    // Can accept precomputed Z^-1 - for example, from invertBatch.
    func toAffine(invertedZ: F? = nil) throws -> AffinePoint<F> {
        let invZ = try invertedZ ?? z.inverted()
        guard !invZ.isZero else {
            throw ToAffineError()
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
    
    func toString(radix: Int = 16, pad: Bool = false) -> String {
        """
        \(Self.self)(
            x: \(x.toString(radix: radix, pad: pad)),
            y: \(y.toString(radix: radix, pad: pad)),
            z: \(z.toString(radix: radix, pad: pad))
        )
        """
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
    mutating func double() {
        self = self.doubled()
    }
    
    // http://hyperelliptic.org/EFD/g1p/auto-shortw-projective.html#addition-add-1998-cmo-2
    // Cost: 12M + 2S + 6add + 1*2.
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
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        lhs + rhs.negated()
    }
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    private static func validate(scalar: BigInt) throws -> BigInt {
        guard scalar > 0 && scalar <= Curve.r else {
            throw InvalidScalar()
        }
        // OK!
        return scalar
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
    private func precompute(window w: Int) -> [Self] {
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
    mutating func calcMultiplyPrecomputes(w: Int) throws {
        guard __storageForPrecomputes[w] == nil else {
            throw PointAlreadyHasPrecomputes()
        }
        __storageForPrecomputes[w] = try Self.normalizeZ(
            points: precompute(window: w)
        )
    }
    
    mutating func clearMultiplyPrecomputes() {
        __storageForPrecomputes = [:]
    }
    
    private func wNAF(n: BigInt) -> Self /*, Self)*/ {
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
    
    // Constant time multiplication. Uses wNAF.
    func multiplyPrecomputed(scalar: BigInt) throws -> Self {
        try wNAF(n: Self.validate(scalar: scalar))
    }
}

struct ToAffineError: Error {}

// Point on G1 curve: (x, y)
// We add z because we work with projective coordinates instead of affine x-y: that's much faster.
public struct PointG1: ProjectivePoint, Equatable {
    public var __storageForPrecomputes: [Int: [Self]] = [:]
    public typealias F = Fp
    
    public let x: F
    public let y: F
    public let z: F
    
    public init(x: F, y: F, z: F = .one) {
        self.x = x
        self.y = y
        self.z = z
    }
}
public extension PointG1 {
    static let base = Self(
        x: Fp(value: Curve.Gx),
        y: Fp(value: Curve.Gy),
        z: Fp.one
    )
    
    init(bytes: some ContiguousBytes) throws {
        self = try Self._from(bytes: bytes)
    }
    enum Error: Swift.Error {
        case invalidByteCount(
            expectedCompressed: Int = BLS.publicKeyCompressedByteCount,
            orUncompressed: Int = BLS.publicKeyCompressedByteCount * 2,
            butGot: Int
        )
        case invalidCompressedPoint
        case invalidPointNotOnCurveFp
        case invalidPointNotOfPrimeOrderSubgroup
    }
    
    private static func _from(bytes: some ContiguousBytes) throws -> Self {
        let point = try bytes.withUnsafeBytes { (bytesPointer) throws -> Self in
            
            if bytesPointer.count == BLS.publicKeyCompressedByteCount {
                let P = Curve.P
                let compressedValue = BigInt(bytesPointer)
                
                let bflag = mod(a: compressedValue, b: BLS.exp2_383) / BLS.exp2_382
                if (bflag == 1) {
                    return Self.zero
                }
                let x = Fp(value: mod(a: compressedValue, b: BLS.exp2_381))
                let ySquared = try x.pow(n: 3) + Self.b
                guard var y = ySquared.sqrt() else {
                    throw Error.invalidCompressedPoint
                }
                
                let aflag = mod(a: compressedValue, b: BLS.exp2_382) / BLS.exp2_381
                
                if ((y.value * 2) / P) != aflag {
                    y.negate()
                    
                }
                return PointG1(x: x, y: y)
            } else if bytesPointer.count == 2*BLS.publicKeyCompressedByteCount {
                // Check if the infinity flag is set
                guard (bytesPointer[0] & (1 << 6)) == 0 else { return .zero }
                
                let x = BigInt(Data(bytesPointer.prefix(BLS.publicKeyCompressedByteCount)))
                let y = BigInt(Data(bytesPointer.suffix(BLS.publicKeyCompressedByteCount)))
                return PointG1(x: Fp(value: x), y: Fp(value: y))
            } else {
                throw Error.invalidByteCount(butGot: bytesPointer.count)
            }
        }
        return try point.assertValidity()
    }
    
    static let b = Fp(value: Curve.b)
    
    private func _isOnCurve() throws -> Bool {
        let left = try y.pow(n: 2) * z - x.pow(n: 3)
        let right = try Self.b * z.pow(n: 3)
        return (left - right).isZero
    }
    /// Checks that equation is fulfilled: `y² = x³ + b`    ///
    func isOnCurve() -> Bool {
        do {
            return try _isOnCurve()
        } catch {
            return false
        }
    }
    
    // [-0xd201000000010000]P
    private func mulCurveX() throws -> Self {
        try unsafeMultiply(scalar: Curve.x).negated()
    }
    
    // [0xd201000000010000]P
    private func mulCurveMinusX() throws -> Self {
        try unsafeMultiply(scalar: Curve.x)
    }
    
    // Checks is the point resides in prime-order subgroup.
    // point.isTorsionFree() should return true for valid points
    // It returns false for shitty points.
    // https://eprint.iacr.org/2021/1130.pdf
    private func _isTorsionFree() throws -> Bool {
        // TODO: fix if outcommented below is better, Noble has this comment
        let xP = try mulCurveX() // [x]P
        let u2P = try xP.mulCurveMinusX() // [u2]P
        let _phi = phi()
        return u2P == _phi
        
        // https://eprint.iacr.org/2019/814.pdf
        // (z² − 1)/3
        // const c1 = 0x396c8c005555e1560000000055555555n;
        // const P = this;
        // const S = P.sigma();
        // const Q = S.double();
        // const S2 = S.sigma();
        // // [(z² − 1)/3](2σ(P) − P − σ²(P)) − σ²(P) = O
        // const left = Q.subtract(P).subtract(S2).multiplyUnsafe(c1);
        // const C = left.subtract(S2);
        // return C.isZero();
    }
    
    /// Checks is the point resides in prime-order subgroup.
    private func isTorsionFree() -> Bool {
        do {
            return try _isTorsionFree()
        } catch {
            return false
        }
    }
    
    @discardableResult
    func assertValidity() throws -> Self {
        if isZero { return self }
        guard isOnCurve() else {
            throw Error.invalidPointNotOnCurveFp
        }
        guard isTorsionFree() else {
            throw Error.invalidPointNotOfPrimeOrderSubgroup
        }
        // all good
        return self
    }
   
    func toData(compress: Bool = false) -> Data {
        try! assertValidity()
   
        var out: BigInt
        if compress {
            let P = Curve.P
            if isZero {
                out = BLS.exp2_383 + BLS.exp2_382
            } else {
                let affine = try! self.toAffine()
                let x = affine.x
                let y = affine.y
                let flag = (y.value * 2) / P
                out = x.value + flag * BLS.exp2_381 + BLS.exp2_383
            }
            return out.serialize(padToLength: BLS.publicKeyCompressedByteCount)
        } else {
            if isZero {
                var out = Data(repeating: 0x00, count: 2 * BLS.publicKeyCompressedByteCount)
                out[0] = 0x04
                return out
            } else {
                let affine = try! self.toAffine()
                let x = affine.x
                let y = affine.y
                return x.value.serialize(padToLength: BLS.publicKeyCompressedByteCount) + y.value.serialize(padToLength: BLS.publicKeyCompressedByteCount)
            }
        }
        
    }
    
    // Sparse multiplication against precomputed coefficients
     func millerLoop(pointG2: PointG2) -> Fp12 {
//       return millerLoop(P.pairingPrecomputes(), this.toAffine())
         fatalError()
     }

    // Clear cofactor of G1
    // https://eprint.iacr.org/2019/403
    func clearCofactor() throws -> Self {
        let t = try mulCurveMinusX()
        return t + self
    }

}

public struct PointG2 {}

extension PointG1 {
    /// `σ endomorphism`
    func sigma() throws -> PointG1 {
        let beta = Frobenius.aaac
        let affine = try toAffine()
        let x = affine.x
        let y = affine.y
        return Self.init(x: x * beta, y: y)
    }
    
    // φ endomorphism
    func phi() -> Self {
        let cubicRootOfUnityModP = Frobenius.fffe
        return Self(
            x: x * cubicRootOfUnityModP,
            y: y,
            z: z
        )
    }
}
