//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation

public struct PublicKey: GroupElementConveritible {
   
    public typealias Group = G1
    
    public let groupElement: G1
   
    public init(groupElement: G1) {
        self.groupElement = groupElement
    }
}

public extension PublicKey {
    
    /// Checks if pairing of public key & hash is equal to pairing of generator & signature.
    /// `e(P, H(m)) == e(G, S)`
    func isValidSignature(
        _ signature: Signature,
        byHashingMessageToCheck messageData: Data
    ) async  -> Bool {
        do {
            return try await _isValidSignature(signature, byHashingMessageToCheck: messageData)
        } catch {
            return false
        }
    }
    
    /// Checks if pairing of public key & hash is equal to pairing of generator & signature.
    /// `e(P, H(m)) == e(G, S)`
    func isValidSignature(
        _ signature: Signature,
        for message: Message
    ) async -> Bool {
        do {
            return try await _isValidSignature(signature, for: message)
        } catch {
            return false
        }
    }
    
    /// Adds a bunch of public key points together.
    /// `pk1 + pk2 + pk3 + ... + pkN = pkA`
    static func aggregate(_ publicKeys: [Self]) throws -> Self {
        guard !publicKeys.isEmpty else {
            throw CannotAggregateEmptyList()
        }
        let aggregatedPoint = publicKeys.map { $0.groupElement.point }.reduce(Group.Point.zero, +)
        return try Self(groupElement: .init(point: aggregatedPoint))
    }
}
struct CannotAggregateEmptyList: Error {}

internal extension PublicKey {
    
    func _isValidSignature(
        _ signature: Signature,
        byHashingMessageToCheck messageToHash: Data
    ) async throws -> Bool {
        let message = try await Message(hashing: messageToHash)
        return try await _isValidSignature(signature, for: message)
    }
    
    func _isValidSignature(
        _ signature: Signature,
        for message: Message
    ) async throws -> Bool {
        let P = groupElement
        let G = G1.generator
        let S = signature.groupElement
        let Hm = message.groupElement
        
        // Instead of doing 2 exponentiations, we use property of billinear maps
        // and do one exp after multiplying 2 points.
        let ePHm = try BLS.pairing(g1: P.negated(), g2: Hm, withFinalExponent: false)
        let eGS = try BLS.pairing(g1: G, g2: S, withFinalExponent: false)
        let exp = try (eGS * ePHm).finalExponentiate()
        let isValid = exp == Fp12.one
        return isValid
    }
    
}
