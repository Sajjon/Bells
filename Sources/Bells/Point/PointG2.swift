//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation

public struct PointG2: ProjectivePoint {
    public var __storageForPrecomputes: [Int : [PointG2]] = [:]
    public let x: Fp2
    public let y: Fp2
    public let z: Fp2
    public init(x: Fp2, y: Fp2, z: Fp2 = .one) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public extension PointG2 {

    init(privateKey: PrivateKey) {
        fatalError()
    }
    
    init(bytes: some ContiguousBytes) throws {
        fatalError()
    }
    
    init(signature: Signature) throws {
        fatalError()
    }
}

public extension PointG2 {
    typealias F = Fp2
    
    static let generator = Self(
        x: Fp2(Curve.G2x),
        y: Fp2(Curve.G2y),
        z: Fp2.one
    )
    
    static let zero = Self(x: .one, y: .one, z: .zero)
}

import BytePattern
public typealias Message = Data
public extension PointG2 {
    
    /// Encodes byte string to elliptic curve
      /// https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#section-3
    static func hashToCurve(
        message: Message,
        hashToFieldConfig: HashToFieldConfig = .defaultForHashToG2
    ) async throws -> Self {
        let u = try await BLS.hashToField(
            message: message,
            elementCount: 2,
            config: hashToFieldConfig
        )

        let t0 = Fp2(c0: u[0][0], c1: u[0][1])
        let Q0 = try Self(simpleProjective: BLS.isogenyMapG2(jacobiPoint: BLS.mapToCurveSimple_swu_9mod16(t: t0)))
        let t1 = Fp2(c0: u[1][0], c1: u[1][1])
        let Q1 = try Self(simpleProjective: BLS.isogenyMapG2(jacobiPoint: BLS.mapToCurveSimple_swu_9mod16(t: t1)))
        
        let R = Q0 + Q1
        let P = try R.clearCofactor()
        return P
    }
    
    /// Checks that equation is fulfilled: `y² = x³ + b`
    func isOnCurve() -> Bool {
        fatalError()
    }
    
    func mulCurveX() throws -> Self {
        try unsafeMultiply(scalar: Curve.x).negated()
    }
    
    
    // Ψ endomorphism
    private func psi() throws -> Self {
        try Self(affine: toAffine().psi())
    }
    
    // Ψ²
    private func psi2() throws -> Self {
        try Self(affine: toAffine().psi2())
    }
    
    // Maps the point into the prime-order subgroup G2.
    // clear_cofactor_bls12381_g2 from cfrg-hash-to-curve-11
    // https://eprint.iacr.org/2017/419.pdf
    func clearCofactor() throws -> Self {
        let P = self
        let t1 = try P.mulCurveX()   // [-x]P
        var t2 = try P.psi()         // Ψ(P)
        var t3 = P.doubled()      // 2P
        t3 = try t3.psi2()           // Ψ²(2P)
        t3 = t3 - t2     // Ψ²(2P) - Ψ(P)
        t2 = t1 + t2          // [-x]P + Ψ(P)
        t2 = try t2.mulCurveX()      // [x²]P - [x]Ψ(P)
        t3 = t3 + t2          // Ψ²(2P) - Ψ(P) + [x²]P - [x]Ψ(P)
        t3 = t3 - t1     // Ψ²(2P) - Ψ(P) + [x²]P - [x]Ψ(P) + [x]P
        let Q = t3 - P // Ψ²(2P) - Ψ(P) + [x²]P - [x]Ψ(P) + [x]P - 1P =>
        return Q                 // [x²-x-1]P + [x-1]Ψ(P) + Ψ²(2P)
    }
}

public extension PointG2 {
    func toSignature() -> Signature {
        fatalError()
    }
    
    // MARK: Data Serialization
    func toData(compress: Bool = false) -> Data {
        fatalError()
    }
}
