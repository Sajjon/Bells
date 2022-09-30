//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//

import Foundation
import BigInt
import RealModule

// MARK: PointG1

/// Point on G1 curve: `(x, y, z)`, in the `Fp` field.
///
/// We add `z` because we work with projective coordinates instead of affine `x-y`,
/// which results in faster performance.
public struct PointG1: ProjectivePoint, Equatable {
    public let __storageForPrecomputes: StorageOfPrecomputedProjectivePoints<Self> = .init()
    public let x: Fp
    public let y: Fp
    public let z: Fp
    
    public init(x: Fp, y: Fp, z: Fp = .one) {
        self.x = x
        self.y = y
        self.z = z
    }
}

// MARK: Init
public extension PointG1 {
    init(bytes: some ContiguousBytes) throws {
        let tuple = try bytes.withUnsafeBytes { (bytesPointer) throws -> (x: Fp, y: Fp) in
            
            if bytesPointer.count == BLS.publicKeyCompressedByteCount {
                let P = Curve.P
                let compressedValue = BigInt(bytesPointer)
                
                let bflag = mod(a: compressedValue, b: BLS.exp2_383) / BLS.exp2_382
                if (bflag == 1) {
                    let zero = Self.zero
                    return (x: zero.x, y: zero.y)
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
                return (x: x, y: y)
            } else if bytesPointer.count == 2*BLS.publicKeyCompressedByteCount {
                // Check if the infinity flag is set
                guard (bytesPointer[0] & (1 << 6)) == 0 else {
                    let zero = Self.zero
                    return (x: zero.x, y: zero.y)
                }
                
                let x = BigInt(Data(bytesPointer.prefix(BLS.publicKeyCompressedByteCount)))
                let y = BigInt(Data(bytesPointer.suffix(BLS.publicKeyCompressedByteCount)))
                return (x: Fp(value: x), y: Fp(value: y))
            } else {
                throw Error.invalidByteCount(butGot: bytesPointer.count)
            }
        }
        
        self.init(x: tuple.x, y: tuple.y)
        try assertValidity()
    }
}

// MARK: Constants
public extension PointG1 {
    typealias F = Fp
    
    /// The generator point of a the group `G1`.
    static let generator = Self(
        x: Fp(value: Curve.Gx),
        y: Fp(value: Curve.Gy),
        z: Fp.one
    )
    
    static let b = Fp(value: Curve.b)
}

// MARK: Public
public extension PointG1 {
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
    
    // Sparse multiplication against precomputed coefficients
     func millerLoop(pointG2 P: PointG2) throws -> Fp12 {
         let ell = try P.pairingPrecomputes()
         let g1 = try self.toAffine()
         return BLS.millerLoop(ell: ell, g1: g1)
     }

    // Clear cofactor of G1
    // https://eprint.iacr.org/2019/403
    func clearCofactor() throws -> Self {
        let t = try mulCurveMinusX()
        return t + self
    }
}

// MARK: ProjectivePoint
public extension PointG1 {
    /// Checks that equation is fulfilled: `y² = x³ + b`
    func isOnCurve() -> Bool {
        do {
            return try _isOnCurve()
        } catch {
            return false
        }
    }
   
    // MARK: Data Serialization
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
}

// MARK: Private
private extension PointG1 {
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
    
    /// Checks is the point resides in prime-order subgroup.
    func isTorsionFree() -> Bool {
        do {
            return try _isTorsionFree()
        } catch {
            return false
        }
    }
    
    // [-0xd201000000010000]P
    func mulCurveX() throws -> Self {
        try unsafeMultiply(scalar: Curve.x).negated()
    }
    
    // [0xd201000000010000]P
    func mulCurveMinusX() throws -> Self {
        try unsafeMultiply(scalar: Curve.x)
    }
    
    // Checks is the point resides in prime-order subgroup.
    // point.isTorsionFree() should return true for valid points
    // It returns false for shitty points.
    // https://eprint.iacr.org/2021/1130.pdf
    func _isTorsionFree() throws -> Bool {
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
    
    func _isOnCurve() throws -> Bool {
        let left = try y.pow(n: 2) * z - x.pow(n: 3)
        let right = try Self.b * z.pow(n: 3)
        return (left - right).isZero
    }
}

extension PointG1 {
    typealias Error = ProjectivePointError
}
