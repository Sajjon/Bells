//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

public protocol EllipticCurve where Group.Curve == Self {
    associatedtype Group: FiniteGroup
    /// The generator point of a group this projective point is an element of.
    static var generator: Group { get }
    static var modulus: BigInt { get }
    static var order: BigInt { get }
    static var cofactor: BigInt { get }
}
public extension EllipticCurve {
    static var maxBits: Int { Self.order.bitWidthIgnoreSign }
}


public extension EllipticCurve {
    /// Modulus, short name.
    static var P: BigInt { modulus }
    /// Order, short name.
    static var r: BigInt { order }
    /// Cofactor, short name.
    static var b: BigInt { order }
}

public protocol FiniteGroup:
    Equatable,
    CustomToStringConvertible,
    ThrowingSignedNumeric,
    ThrowingAdditiveArtithmetic,
    ThrowingMultipliableByScalarArtithmetic
where Curve.Group == Self {
    associatedtype Curve: EllipticCurve
    associatedtype Point: ProjectivePoint
    
    static var identity: Self { get }
    
    var point: Point { get }
    var isZero: Bool { get }
    init(point: Point) throws
    init(bytes: some ContiguousBytes) throws
    init(uncompressedData: Data) throws
    init(compressedData: Data) throws
    
    func toData(compress: Bool) -> Data
}

public extension FiniteGroup {
    static var generator: Self { Self.Curve.generator }
    static func + (lhs: Self, rhs: Self) throws -> Self {
        try op(lhs, rhs, +)
    }
    static func * (lhs: Self, scalar: BigInt) throws -> Self {
        try self.init(point: lhs.point * scalar)
    }
    func negated() throws -> Self {
        try Self(point: point.negated())
    }
}
private extension FiniteGroup {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Point, Point) throws -> Point) throws -> Self {
        try .init(point: operation(lhs.point, rhs.point))
    }
}


public extension FiniteGroup {
    
    init(x: Point.F, y: Point.F, z: Point.F) throws {
        try self.init(point: Point(x: x, y: y, z: z))
    }
    
    var isZero: Bool { point.isZero }
    
    static var identity: Self {
        try! .init(
            point: .init(x: .zero, y: .one, z: .zero)
        )
    }
    init(bytes: some ContiguousBytes) throws {
        try self.init(point: Point(bytes: bytes))
    }
    init(uncompressedData: Data) throws {
        try self.init(point: Point(uncompressedData: uncompressedData))
    }
    init(compressedData: Data) throws {
        try self.init(point: Point(compressedData: compressedData))
    }
    func toData(compress: Bool = false) -> Data {
        point.toData(compress: compress)
    }
}
public extension FiniteGroup {
    var x: Point.F { point.x }
    var y: Point.F { point.y }
    var z: Point.F { point.z }
    
    func toString(radix: Int, pad: Bool) -> String {
        point.toString(radix: radix, pad: pad)
    }
}
