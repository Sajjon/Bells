//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-03.
//

import Foundation

public struct Signature: Equatable, GroupElementConveritible {
    public typealias Group = G2
    public let groupElement: G2
    
    public init(groupElement: G2) {
        self.groupElement = groupElement
    }
}
