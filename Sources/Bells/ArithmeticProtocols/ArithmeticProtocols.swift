//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-28.
//

import Foundation
import BigInt

public extension AdditiveArithmetic {
    var isZero: Bool { self == .zero }
}

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

public protocol MultipliableByScalarArtithmetic {
    /// Multiplies left-hand-side variable with the right-hand-side scalar
    /// and returns the product, having the same type as the left-hand-side
    /// variable.
    static func * (lhs: Self, scalar: BigInt) -> Self
 
    /// Multiplies left-hand-side variable with the right-hand-side scalar
    /// and stores the product in the left-hand-side variable.
    ///
    /// Default implementation provided.
    static func *= (lhs: inout Self, scalar: BigInt)
}
public extension MultipliableByScalarArtithmetic {
    /// Multiplies left-hand-side variable with the right-hand-side scalar
    /// and stores the product in the left-hand-side variable.
    static func *= (lhs: inout Self, scalar: BigInt) {
        lhs = lhs * scalar
    }
    
    /// Multiplication is commutative
    static func * (lhs: BigInt, rhs: Self) -> Self {
        rhs * lhs
    }
    
    static func * (lhs: Int, rhs: Self) -> Self {
        BigInt(lhs) * rhs
    }
  
    static func * (lhs: Self, rhs: Int) -> Self {
        lhs * BigInt(rhs)
    }
}

public protocol DivisibleByScalarArithmetic {
    /// Divides the left-hand-side variable with the right-hand-side scalar
    /// and returns the result, having the same type as the left-hand-side
    /// variable.
    static func / (lhs: Self, scalar: BigInt) throws -> Self
    
    /// Divides the left-hand-side variable with the right-hand-side scalar
    /// and stores the product in the left-hand-side variable.
    ///
    /// Default implementation provided.
    static func /= (lhs: inout Self, scalar: BigInt) throws
}

public extension DivisibleByScalarArithmetic {
    /// Divides the left-hand-side variable with the right-hand-side scalar
    /// and stores the product in the left-hand-side variable.
    static func /= (lhs: inout Self, scalar: BigInt) throws {
        lhs = try lhs / scalar
    }
}

public protocol ThrowingMultipliableByScalarArtithmetic {
    /// Multiplies left-hand-side variable with the right-hand-side scalar
    /// and returns the product, having the same type as the left-hand-side
    /// variable.
    static func * (lhs: Self, scalar: BigInt) throws -> Self
 
    /// Multiplies left-hand-side variable with the right-hand-side scalar
    /// and stores the product in the left-hand-side variable.
    ///
    /// Default implementation provided.
    static func *= (lhs: inout Self, scalar: BigInt) throws
}
public extension ThrowingMultipliableByScalarArtithmetic {
    /// Multiplies left-hand-side variable with the right-hand-side scalar
    /// and stores the product in the left-hand-side variable.
    static func *= (lhs: inout Self, scalar: BigInt) throws {
        lhs = try lhs * scalar
    }
    
    /// Multiplication is commutative
    static func * (lhs: BigInt, rhs: Self) throws -> Self {
        try rhs * lhs
    }
    
    static func * (lhs: Int, rhs: Self) throws -> Self {
        try BigInt(lhs) * rhs
    }
  
    static func * (lhs: Self, rhs: Int) throws -> Self {
        try lhs * BigInt(rhs)
    }
}
