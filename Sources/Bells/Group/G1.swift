//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

// MARK: G1

///
/// Element of the cyclic subgroup of `E(GF(p))` of `order r`. This element has a
/// projective point `(x, y, z)` in the `Fp` field (`E(GF(p))`),
/// that **guaranteed** be on the curve.
public struct G1: FiniteGroup, Equatable {
    public let point: Point
    
    public init(point: Point) throws {
        self.point =  try point.assertValidity()
    }
}

public extension G1 {
    typealias Point = P1
    
    /// `E₁: y² = x³ + 4`
    enum Curve: EllipticCurve {}
}

public extension G1.Curve {
    typealias Group = G1
    /// G1 is the order-q subgroup of `E1(Fp) : y² = x³ + 4, #E1(Fp) = h1q`
    /// where characteristic: `z + (z⁴ - z² + 1)(z - 1)²/3`
    static var modulus: BigInt = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab", radix: 16)!
    
    /// Order: `z⁴ − z² + 1`
    static let order = BigInt("73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001", radix: 16)!
    
    /// Cofactor: `(z - 1)²/3`
    static let cofactor = BigInt("396c8c005555e1568c00aaab0000aaab", radix: 16)!
    
    /// The generator point of a the group `G1`, with coordinates
    /// x = 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507
    /// y = 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569
    static let generator = try! G1(
        x: Fp(value: BigInt("17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb", radix: 16)!),
        y: Fp(value: BigInt("08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1", radix: 16)!),
        z: .one
    )
    
    static let b: BigInt = 4
    /// The BLS parameter x for BLS12-381
    static let x = BigInt("d201000000010000", radix: 16)!
}
