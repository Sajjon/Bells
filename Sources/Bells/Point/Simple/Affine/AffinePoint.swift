//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation

public struct AffinePoint<F: Field>: Equatable {
    public let x: F
    public let y: F
    public init(x: F, y: F) {
        self.x = x
        self.y = y
    }
}

public extension AffinePoint {
    func toString(radix: Int = 16, pad: Bool = false) -> String {
        """
        Affine(
            x: \(x.toString(radix: radix, pad: pad)),
            y: \(y.toString(radix: radix, pad: pad)
        )
        """
    }
}
