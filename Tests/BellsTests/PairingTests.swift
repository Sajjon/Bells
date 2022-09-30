//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-30.
//

import Foundation
import XCTest
@testable import Bells

let G1 = PointG1.generator
let G2 = PointG2.generator

final class PairingTests: XCTestCase {
    
    func test_pairing() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        let p2 = try BLS.pairing(P: G1.negated(), Q: G2)
        XCTAssertEqual(p1 * p2, Fp12.one)
    }
    
}

