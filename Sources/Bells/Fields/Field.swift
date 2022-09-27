//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import BigInt
import Foundation

/// A version of Numeric without `ExpressibleByIntegerLiteral`  or `Magnitude` requirement.
public protocol Numeric_: AdditiveArithmetic {
    /// Multiplies two values and produces their product.
    static func * (lhs: Self, rhs: Self) -> Self
 
    /// Multiplies two values and stores the result in the left-hand-side variable.
    ///
    /// Default implementation provided.
    static func *= (lhs: inout Self, lhs: Self)
}

public extension Numeric_ {
    
    /// Multiplies two values and stores the result in the left-hand-side variable.
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

/// A version of Numeric without `ExpressibleByIntegerLiteral`  or `Magnitude` requirement.
public protocol SignedNumeric_ {
    
    /// Returns the additive inverse of the self.
    func negated() -> Self
    
    /// Returns the additive inverse of the specified value.
    ///
    /// Default implementation provided.
    static prefix func - (operand: Self) -> Self
 
    /// Replaces this value with its additive inverse.
    ///
    /// Default implementation provided.
    mutating func negate()
}

extension AdditiveArithmetic where Self: SignedNumeric_ {
    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs + rhs.negated()
    }
}

public extension SignedNumeric_ {
    
    /// Returns the additive inverse of the specified value.
    static prefix func - (operand: Self) -> Self {
        operand.negated()
    }
    
    /// Replaces this value with its additive inverse.
    mutating func negate() {
        self = negated()
    }
}

public protocol DivisionArithmetic {
    
    /// Divides the left-hand-side variable with the right-hand-side variable
    /// and returns the result
    static func / (lhs: Self, rhs: Self) throws -> Self
    
    /// Divides the left-hand-side variable with the right-hand-side variable
    /// and stores the result in the left-hand-side variable.
    ///
    /// Default implementation provided.
    static func /= (lhs: inout Self, rhs: Self) throws
}
public extension DivisionArithmetic {
    /// Divides the left-hand-side variable with the right-hand-side variable
    /// and stores the result in the left-hand-side variable.
    static func /= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs / rhs
    }
}

/// Finite field
public protocol Field:
    Equatable,
    Numeric_,
    SignedNumeric_,
    DivisionArithmetic,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    static var one: Self { get }
    static func * (lhs: Self, rhs: BigInt) -> Self
    static func / (lhs: Self, rhs: BigInt) throws -> Self
    
    /// Multiplicative inverse of a nonzero element.
    func inverted() throws -> Self

    func squared() throws -> Self
    func pow(n: BigInt) throws -> Self

    func toString(radix: Int, pad: Bool) -> String
}

public extension Field {
    
    var description: String {
        toDecimalString(pad: false)
    }
    
    func toDecimalString(pad: Bool = false) -> String {
        toString(radix: 10, pad: pad)
    }
    
    func toHexString(pad: Bool = true) -> String {
        toString(radix: 16, pad: pad)
    }
    
    var debugDescription: String {
        toHexString(pad: true)
    }
}

public extension Field {
    
 
//    static func += (lhs: inout Self, rhs: Self) {
//        lhs = lhs + rhs
//    }
//    static func -= (lhs: inout Self, rhs: Self) {
//        lhs = lhs - rhs
//    }
//    static func /= (lhs: inout Self, rhs: Self) throws {
//        try lhs = lhs / rhs
//    }
    
    var isZero: Bool { self == .zero }


    static func * (lhs: BigInt, rhs: Self) -> Self {
        rhs * lhs
    }

    static func * (lhs: Int, rhs: Self) -> Self {
        BigInt(lhs) * rhs
    }
  
}

public protocol FiniteField: Field {
    static var order: BigInt { get }
    static var maxBits: Int { get }
}
