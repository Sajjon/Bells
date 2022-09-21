//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

/// Finite field
public protocol Field: AdditiveArithmetic, CustomStringConvertible {
    func negated() -> Self
    func inverted() throws -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func / (lhs: Self, rhs: Self) throws -> Self
    static func * (lhs: Self, rhs: BigInt) -> Self
    static func / (lhs: Self, rhs: BigInt) throws -> Self
    func squared() throws -> Self
    func pow(n: BigInt) throws -> Self
    
    static var one: Self { get }
}

public extension Field {
    var isZero: Bool { self == .zero }
}


public protocol FiniteField: Field {
    static var order: BigInt { get }
}
