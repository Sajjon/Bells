//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

/// To verify curve parameters, see pairing-friendly-curves spec:
/// https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-pairing-friendly-curves-09
/// Basic math is done over finite fields over `p`.
/// More complicated math is done over polynominal extension fields.
/// To simplify calculations in `Fp12`, we construct extension tower:
/// ```
/// Fp₁₂ = Fp₆² => Fp₂³
/// Fp(u) / (u² - β) where β = -1
/// Fp₂(v) / (v³ - ξ) where ξ = u + 1
/// Fp₆(w) / (w² - γ) where γ = v
/// ```
public enum Curve {}
public extension Curve {
    /// G1 is the order-q subgroup of `E1(Fp) : y² = x³ + 4, #E1(Fp) = h1q`
    /// where characteristic: `z + (z⁴ - z² + 1)(z - 1)²/3`
    static let P = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab", radix: 16)!
    
    /// Order: `z⁴ − z² + 1`
    static let r = BigInt("73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001", radix: 16)!
    
    /// Cofactor: `(z - 1)²/3`
    static let h = BigInt("396c8c005555e1568c00aaab0000aaab", radix: 16)!
    
    /// generator's coordinates
    /// x = 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507
    /// y = 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569
    static let Gx = BigInt("17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb", radix: 16)!
    static let Gy = BigInt("08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1", radix: 16)!
    
    static let b: BigInt = 4

    /// G2 is the order-q subgroup of E2(Fp²) : y² = x³+4(1+√−1),
    /// where Fp2 is Fp[√−1]/(x2+1). #E2(Fp2 ) = h2q, where
    /// G² - 1
    /// h2q
    static let P2 = P.power(2) - 1
    
    /// Cofactor
    static let h2 = BigInt("5d543a95414e7f1091d50792876a202cd91de4547085abaa68a205b2e5a7ddfa628f1cb4d9e82ef21537e293a6691ae1616ec6e786f0c70cf1c38e31c7238e5", radix: 16)!
    
    static let G2x = (
        x: BigInt("024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8", radix: 16)!,
        y: BigInt("13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e", radix: 16)!
    )
    
    /// y =
    /// 927553665492332455747201965776037880757740193453592970025027978793976877002675564980949289727957565575433344219582,
    /// 1985150602287291935568054521177171638300868978215655730859378665066344726373823718423869104263333984641494340347905
    static let G2y = (
        x: BigInt("0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801", radix: 16)!,
        y: BigInt("0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be", radix: 16)!
    )
    
    static let b2 = [4, 4]
    
    /// The BLS parameter x for BLS12-381
    static let x = BigInt("d201000000010000", radix: 16)!
    static let h2Eff = BigInt("bc69f08f2ee75b3584c6a0ea91b352888e2a8e9145ad7689986ff031508ffe1329c2f178731db956d82bf015d1212b02ec0ec69d7477c1ae954cbc06689f6a359894c0adebbf6b4e8020005aaa95551", radix: 16)!
};
