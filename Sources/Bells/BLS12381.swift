//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//

import Foundation
import BigInt

public enum BLS {}
public extension BLS {
    
    /// `C_bit`, compression bit for serialization flag
    static let exp2_381 = BigInt(2).power(381)
    
    /// `I_bit`, point-at-infinity bit for serialization flag
    static let exp2_382 = exp2_381 * 2
    
    /// `S_bit`, sign bit for serialization flag
    static let exp2_383 = exp2_382 * 2
    
    static let publicKeyByteCount = 48
}
