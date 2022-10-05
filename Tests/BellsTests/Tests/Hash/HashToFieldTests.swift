//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-29.
//

import Foundation
@testable import Bells
import XCTest
import BigInt

final class HashToFieldTests: XCTestCase {
        
    func test_hash_to_field() async throws  {
        
        let dst: DomainSeperationTag = "QUUX-V01-CS02-with-BLS12381G2_XMD:SHA-256_SSWU_RO_"
        let m: Int = 0x2 // 2
        let k: Int = 0x80 // 128
        let p = BigInt(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab")
        XCTAssertEqual(p, G1.Curve.P)
        
        let config = HashToFieldConfig(domainSeperationTag: dst, p: p, m: m, k: k)
        XCTAssertEqual(config, .init(domainSeperationTag: dst))
        
        let u = try await BLS.hashToField(
            message: "abcdef0123456789".data(using: .utf8)!,
            elementCount: 2,
            config: config
        ).flatMap { $0 }
        let expected: [BigInt] = [
            [
                BigInt(hex: "0x0313d9325081b415bfd4e5364efaef392ecf69b087496973b229303e1816d2080971470f7da112c4eb43053130b785e1"),
                BigInt(hex: "0x062f84cb21ed89406890c051a0e8b9cf6c575cf6e8e18ecf63ba86826b0ae02548d83b483b79e48512b82a6c0686df8f")
            ],
            [
                BigInt(hex: "0x1739123845406baa7be5c5dc74492051b6d42504de008c635f3535bb831d478a341420e67dcc7b46b2e8cba5379cca97"),
                BigInt(hex: "0x01897665d9cb5db16a27657760bbea7951f67ad68f8d55f7113f24ba6ddd82caef240a9bfa627972279974894701d975"),
            ]
        ].flatMap { $0 }
        XCTAssertEqual(u, expected)
    }
}
