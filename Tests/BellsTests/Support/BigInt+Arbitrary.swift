//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-19.
//

import Foundation
import SwiftCheck
import BigInt

func secureRandomBytes(byteCount: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: byteCount)
    let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    
    guard result == errSecSuccess else {
        fatalError("Problem generating random bytes")
    }
    
    return bytes
}


extension BigInt {
    
    static func random(byteCount: Int = 48) -> Self {
        let uintByteCount = Word.bitWidth / 8
        precondition(byteCount.isMultiple(of:  uintByteCount))
        let bytes = secureRandomBytes(byteCount: byteCount)
        return Self(bytes: bytes)
    }
    
    init(bytes: [UInt8]) {
        let uintByteCount = Word.bitWidth / 8
        precondition(bytes.count.isMultiple(of:  uintByteCount))
        
        let words: [Word] = bytes.chunks(ofCount: uintByteCount).map { chunk in
            chunk.withUnsafeBytes {
                $0.load(as: Word.self)
            }
        }
        self.init(words: words)
    }
}

extension BigInt: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            let bytes = (0..<48).map { _ in composer.generate(using: UInt8.arbitrary) }
            return Self(bytes: bytes)
        }
    }
}
