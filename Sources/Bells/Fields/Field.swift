//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import BigInt
import Foundation

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
    static prefix func - (this: Self) -> Self
}

public extension Field {
    
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    static func /= (lhs: inout Self, rhs: Self) throws {
        try lhs = lhs / rhs
    }
    
    var isZero: Bool { self == .zero }
    static prefix func - (this: Self) -> Self {
        this.negated()
    }

    static func * (lhs: BigInt, rhs: Self) -> Self {
        rhs * lhs
    }

    static func * (lhs: Int, rhs: Self) -> Self {
        BigInt(lhs) * rhs
    }
}

public protocol FiniteField: Field {
    static var order: BigInt { get }
}
