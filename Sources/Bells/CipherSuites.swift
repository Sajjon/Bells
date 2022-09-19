////
////  File.swift
////  
////
////  Created by Alexander Cyon on 2022-09-18.
////
//
//import Foundation
//
//public struct DomainSeperationTag: Equatable, ExpressibleByStringLiteral {
//    public let data: Data
//    public init(stringLiteral value: StringLiteralType) {
//        self.init(value)
//    }
//    public init(_ dst: String) {
//        self.init(data: dst.data(using: .utf8)!)
//    }
//    public init(data: Data) {
//        self.data = data
//    }
//}
//
//public enum Core {}
//private extension Core {
//    static func _aggregateVerify(
//        ciphersuite: any Ciphersuite.Type,
//        publicKeys: [PublicKey],
//        messages: [Message],
//        signature: Signature,
//        domainSeperationTag: DomainSeperationTag
//    ) throws -> Bool {
//        guard publicKeys.allSatisfy({ ciphersuite.validatePublicKey($0) }) else {
//            return false
//        }
//        guard messages.allSatisfy({ ciphersuite.validateMessage($0) }) else {
//            return false
//        }
//        guard publicKeys.count == messages.count else {
//            return false
//        }
//        guard ciphersuite.validateSignature(signature) else {
//            return false
//        }
//        guard publicKeys.count >= 1 else {
//            return false
//        }
//        // Procedure
//        let signaturePoint = signatureToG2(signature)
//        fatalError()
//    }
//}
//public extension Core {
//    static func aggregateVerify(
//        ciphersuite: any Ciphersuite.Type,
//        publicKeys: [PublicKey],
//        messages: [Message],
//        signature: Signature,
//        domainSeperationTag: DomainSeperationTag
//    ) -> Bool {
//        do {
//            return try _aggregateVerify(
//                ciphersuite: ciphersuite,
//                publicKeys: publicKeys,
//                messages: messages,
//                signature: signature,
//                domainSeperationTag: domainSeperationTag
//            )
//        } catch {
//            return false
//        }
//    }
//}
//
//public typealias Message = Data
//
//// MARK: Ciphersuite
//public protocol Ciphersuite {
//    static var domainSeperationTag: DomainSeperationTag { get }
//    static func validateSignature(_ signature: Signature) -> Bool
//    static func validateMessage(_ message: Message) -> Bool
//    static func validatePublicKey(_ publicKey: PublicKey) -> Bool
//}
//public extension Ciphersuite {
//    static func validateSignature(_ signature: Signature) -> Bool { false }
//    static func validateMessage(_ message: Message) -> Bool { false }
//    static func validatePublicKey(_ publicKey: PublicKey) -> Bool { false }
//}
//
//
//// MARK: G2Basic
//public enum G2Basic: Ciphersuite {}
//public extension G2Basic {
//    static let domainSeperationTag: DomainSeperationTag = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_"
//}
//public extension G2Basic {
//    static func aggregateVerify(
//        publicKeys: [PublicKey],
//        messages: [Message],
//        signature: Signature
//    ) -> Bool {
//        guard Set(messages).count == messages.count else {
//            // Messages not unique
//            return false
//        }
//        return Core.aggregateVerify(
//            ciphersuite: Self.self,
//            publicKeys: publicKeys,
//            messages: messages,
//            signature: signature,
//            domainSeperationTag: domainSeperationTag
//        )
//    }
//}
//
//// MARK: G2MessageAugmentation
//public enum G2MessageAugmentation: Ciphersuite {}
//public extension G2MessageAugmentation {
//    static let domainSeperationTag: DomainSeperationTag = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_AUG_"
//}
//
//// MARK: G2ProofOfPossession
//public enum G2ProofOfPossession: Ciphersuite {}
//public extension G2ProofOfPossession {
//    static let domainSeperationTag: DomainSeperationTag = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_POP_"
//}
//
