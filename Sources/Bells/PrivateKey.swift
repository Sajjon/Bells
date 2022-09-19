// MARK: PrivateKey
public struct PrivateKey {}
public extension PrivateKey {
    func publicKey() -> PublicKey {
        fatalError()
    }
}
