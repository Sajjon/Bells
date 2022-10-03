//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-03.
//

import Foundation

public struct Message: Equatable, GroupElementConveritible {
    public typealias Group = G2
    public let groupElement: G2
    
    public init(groupElement: G2) {
        self.groupElement = groupElement
    }
}

public extension Message {
    init(hashing data: Data) async throws {
        let p2 = try await P2.hashToCurve(message: data)
        try self.init(groupElement: .init(point: p2))
    }
}
