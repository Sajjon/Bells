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

public extension PointG2 {
    static func hashToCurve(message: Data) async throws -> Self {
        
        let u = try await BLS.hashToField(
            message: message,
            elementCount: 2
        )
        fatalError()
    }
    
    /// Checks that equation is fulfilled: `y² = x³ + b`
    func isOnCurve() -> Bool {
        fatalError()
    }
    
    func clearCofactor() -> Self {
        fatalError()
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
