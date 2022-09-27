//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//

import Foundation
import BigInt
import RealModule

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
