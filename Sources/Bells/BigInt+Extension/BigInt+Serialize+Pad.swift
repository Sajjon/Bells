//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation
import BigInt

extension BigInt {
    
    func serialize(
        padToLength: Int? = nil,
        with pad: UInt8 = 0x00
    ) -> Data {
        let data = serialize()
        guard let padToLength, padToLength > data.count else { return data }
        return data + Data([UInt8](
            repeating: pad,
            count: padToLength - data.count
        ))
    }
}
