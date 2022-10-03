# Bells

BLS12-381 in pure Swift.

# Security
☢️ NOT PRODUCTION READY ☢️

# Usage

In honor of [Noble][noble] I've used same example private key and message

```swift
let privateKey = try PrivateKey(scalar: .init(hex: "67d53f170b908cabb9eb326c3c337762d59289a8fec79f7bc9254b584b73265c"))
let messageData = try Data(hex: "64726e3da8")

let publicKey = privateKey.publicKey()

let (signature, message) = try await privateKey.sign(hashing: messageData)

let isValid = await publicKey.isValidSignature(signature, for: message)
XCTAssertTrue(isValid)

assert(publicKey.toHex(compress: true) == "a7e75af9dd4d868a41ad2f5a5b021d653e31084261724fb40ae2f1b1c31c778d3b9464502d599cf6720723ec5c68b59d")
        
assert(message.toHex(compress: true) ==  "a699307340f1f399717e7009acb949d800d09bda1be7f239179d2e2fd9096532e5f597b3d736412bd6cd073ca4fe8056038fa6a09f5ef9e47a9c61d869d8c069b487e64a57f701b2e724fa8cce8fce050d850eeb1b4a39195ce71eed0cb5c807")

assert(signature.toHex(compress: true) == "b22317bfdb10ba592724c27d0cdc51378e5cd94a12cd7e85c895d2a68e8589e8d3c5b3c80f4fe905ef67aa7827617d04110c5c5248f2bb36df97a58c541961ed0f2fcd0760e9de5ae1598f27638dd3ddaebeea08bf313832a57cfdb7f2baaa03")
        
```

# Acknowledgment
Using [Noble-BLS12-381][noble] as reference, it has been instrumental in the implementation of Bells.

[noble]: https://github.com/paulmillr/noble-bls12-381
