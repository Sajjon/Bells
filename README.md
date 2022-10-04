# Bells

BLS12-381 in pure Swift (first in the world 2022 October).

# Security
☢️ NOT PRODUCTION READY ☢️

# Usage

In honor of [Noble][noble] I've used same example private key and message

## Sign message with one key and validate

```swift
let privateKey = try PrivateKey(scalar: .init(hex: "67d53f170b908cabb9eb326c3c337762d59289a8fec79f7bc9254b584b73265c"))
let messageData = try Data(hex: "64726e3da8")
let publicKey = privateKey.publicKey()
let (signature, message) = try await privateKey.sign(hashing: messageData)
let isValid = await publicKey.isValidSignature(signature, for: message)

assert(isValid)
assert(publicKey.toHex(compress: true) == "a7e75af9dd4d868a41ad2f5a5b021d653e31084261724fb40ae2f1b1c31c778d3b9464502d599cf6720723ec5c68b59d")
assert(message.toHex(compress: true) ==  "a699307340f1f399717e7009acb949d800d09bda1be7f239179d2e2fd9096532e5f597b3d736412bd6cd073ca4fe8056038fa6a09f5ef9e47a9c61d869d8c069b487e64a57f701b2e724fa8cce8fce050d850eeb1b4a39195ce71eed0cb5c807")
assert(signature.toHex(compress: true) == "b22317bfdb10ba592724c27d0cdc51378e5cd94a12cd7e85c895d2a68e8589e8d3c5b3c80f4fe905ef67aa7827617d04110c5c5248f2bb36df97a58c541961ed0f2fcd0760e9de5ae1598f27638dd3ddaebeea08bf313832a57cfdb7f2baaa03")
        
```

## Sign message with many keys and validate
```swift
let privateKeys = try [
    "18f020b98eb798752a50ed0563b079c125b0db5dd0b1060d1c1b47d4a193e1e4",
    "23eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000000",
    "16ae669f3be7a2121e17d0c68c05a8f3d6bef21ec0f2315f1d7aec12484e4cf5"
].map { try PrivateKey(scalar: .init(hex: $0)) }
  
// Perform hash to curve once, instead of of once per signer.
let message = try await Message(hashing: Data(hex: "64726e3da8"))
let publicKeys = privateKeys.map { $0.publicKey() }
let signatures = try await privateKeys.asyncMap { try await $0.sign(message: message) }
let aggregatedPublicKey = try PublicKey.aggregate(publicKeys)
let aggregatedSignature = try Signature.aggregate(signatures)

let isValid = await aggregatedPublicKey.isValidSignature(aggregatedSignature, for: message)

assert(isValid)
assert(aggregatedPublicKey.toHex(compress: true) == "99f1d4ae64167802393b76a3a14719ee449b59a0e5440ee9d8cc27eedbf42d0783430598ada1d8027910d8d8c2511461")
assert(aggregatedSignature.toHex(compress: true) == "8ba8334c1abba0bd490b14bae814d9e674a6f649dfbe72be2e6caf9b882f0a5b5612fc7ff1865c15f1d3b36faae71322063d92170fa2eaed48a3fddcfd5a2a1de29cb05bdd70ac6e7d7d103e913dc187a56aa1d18229d635f6ca6dddfc8d0cff")
assert(message.toHex(compress: true) == "a699307340f1f399717e7009acb949d800d09bda1be7f239179d2e2fd9096532e5f597b3d736412bd6cd073ca4fe8056038fa6a09f5ef9e47a9c61d869d8c069b487e64a57f701b2e724fa8cce8fce050d850eeb1b4a39195ce71eed0cb5c807")
```

## Sign many messages with many keys and validate

```swift
// Sign 3 msg with 3 keys
let privateKeys = try [
    "18f020b98eb798752a50ed0563b079c125b0db5dd0b1060d1c1b47d4a193e1e4",
    "23eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000000",
    "16ae669f3be7a2121e17d0c68c05a8f3d6bef21ec0f2315f1d7aec12484e4cf5"
].map { try PrivateKey(scalar: .init(hex: $0)) }

let messages = try ["d2", "0d98", "05caf3"].map { try Data(hex: $0) }

let publicKeys = privateKeys.map { $0.publicKey() }
let signaturesAndMessages = try await privateKeys.enumerated().asyncMap({ i, sk in
    try await sk.sign(hashing: messages[i])
})

let aggregatedSignature = try Signature.aggregate(signaturesAndMessages.map { $0.signature })

let isValid = await PublicKey.isValidSignature(
    aggregatedSignature,
    forMessages: signaturesAndMessages.map { $0.message },
    publicKeysOfSigners: publicKeys
)
```

# Acknowledgment
Using [Noble-BLS12-381][noble] as reference, it has been instrumental in the implementation of Bells.

[noble]: https://github.com/paulmillr/noble-bls12-381
