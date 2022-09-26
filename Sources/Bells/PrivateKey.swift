import BigInt

// MARK: PrivateKey
public struct PrivateKey {
    private let scalar: BigInt
    public init(scalar: BigInt) throws {
        guard scalar > 0 && scalar <= Curve.r else {
            throw Error.invalidPrivateKey
        }
        self.scalar = scalar
    }
}
public extension PrivateKey {
    
    enum Error: Swift.Error {
        case invalidPrivateKey
    }
    
    func publicKey() -> PublicKey {
        try! .init(point: PointG1.base.multiplyPrecomputed(scalar: scalar))
    }
}
