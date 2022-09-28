//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-28.
//

import Foundation
import BigInt

/// A Finite algebraic field.
public protocol FiniteField: Field {
    static var order: BigInt { get }
    static var maxBits: Int { get }
}
