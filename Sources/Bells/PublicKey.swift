//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation

public struct PublicKey: Equatable {
    public let point: PointG1
    public init(point: PointG1) {
        self.point = point
    }
}
