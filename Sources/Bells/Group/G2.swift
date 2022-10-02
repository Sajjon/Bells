//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

// MARK: G2

/// Element of the cyclic subgroup of `E(GF(p^k))` of `order r`.
/// This element has a with a projective point `(x, y , z)` in the `Fp2` field (`E(GF(p^k))`),
/// that **guaranteed** be on the curve.
public struct G2: FiniteGroup, Equatable {
    
    public let point: Point
    
    public init(point: Point) throws {
        self.point =  try point.assertValidity()
    }
}

public extension G2 {
    typealias Point = P2
    
    /// `E₂: y² = x³ + 4(u+1)`
    enum Curve: EllipticCurve {}
}

public extension G2.Curve {
    typealias Group = G2
    
    /// G2 is the order-q subgroup of E2(Fp²) : y² = x³+4(1+√−1),
    /// where Fp2 is Fp[√−1]/(x2+1). #E2(Fp2 ) = h2q, where
    /// G² - 1
    /// h2q
    static let modulus = G1.Curve.P.power(2) - 1
    
    static let order = G1.Curve.order
    
    /// Cofactor
    static let cofactor = BigInt("5d543a95414e7f1091d50792876a202cd91de4547085abaa68a205b2e5a7ddfa628f1cb4d9e82ef21537e293a6691ae1616ec6e786f0c70cf1c38e31c7238e5", radix: 16)!
    
    static let generator = try! G2(
        point: .init(
            x: .init(
                c0: BigInt("024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8", radix: 16)!,
                c1: BigInt("13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e", radix: 16)!
            ),
            y: .init(
                c0: BigInt("0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801", radix: 16)!,
                c1: BigInt("0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be", radix: 16)!
            ),
            z: .one
        )
    )
    
    /// The BLS parameter `x` for BLS12-381
    static let x = G1.Curve.x
    
    static let b = (4, 4)
    
    
    static let hEff = BigInt("bc69f08f2ee75b3584c6a0ea91b352888e2a8e9145ad7689986ff031508ffe1329c2f178731db956d82bf015d1212b02ec0ec69d7477c1ae954cbc06689f6a359894c0adebbf6b4e8020005aaa95551", radix: 16)!
}
