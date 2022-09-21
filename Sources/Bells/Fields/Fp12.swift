//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

public struct Fp12: Field, CustomDebugStringConvertible {
    
}

public extension Fp12 {
    
    var description: String {
        """
        hej
        """
    }
    var debugDescription: String {
        """
        hej
        """
    }
}

public extension Fp12 {
    static let order: Self = { fatalError() }()
    static let zero: Self = { fatalError() }()
    static let one: Self = { fatalError() }()
    
    func negated() -> Self {
        fatalError()
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }
    static func - (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }
    
    static func / (lhs: Self, rhs: Self) throws -> Self {
        fatalError()
    }
    
    static func * (lhs: Self, rhs: BigInt) -> Self {
        fatalError()
    }
    
    static func / (lhs: Self, rhs: BigInt) throws -> Self {
        fatalError()
    }
    
 
    func inverted() throws -> Self {
        fatalError()
    }
    
    func squared() -> Self {
        fatalError()
    }
    
    
    func pow(n: BigInt) throws -> Self {
        fatalError()
    }
    

}

