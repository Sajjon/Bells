//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-30.
//

import Foundation
import XCTest
@testable import Bells
import BigInt

let G1 = PointG1.generator
let G2 = PointG2.generator

final class PairingTests: XCTestCase {
    
    func test_pairing() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        let p2 = try BLS.pairing(P: G1.negated(), Q: G2)
        XCTAssertEqual(p1 * p2, Fp12.one)
    }
    
    func test_creates_negative_G2_pairing() throws {
        let p1 = try BLS.pairing(P: G1.negated(), Q: G2)
        let p2 = try BLS.pairing(P: G1, Q: G2.negated())
        XCTAssertEqual(p1, p2)
    }
    
    func test_creates_proper_pairing_output_order() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        let p2 = try p1.pow(n: Curve.r)
        XCTAssertEqual(p2, Fp12.one)
    }
    
    func test_G1_billinearity() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        let p2 = try BLS.pairing(P: G1 * 2, Q: G2)
        XCTAssertEqual(p1 * p1, p2)
    }
    
    
    // Vector from https://github.com/zkcrypto/pairing
    func test_vector() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        XCTAssertEqual(
            p1,
            Fp12(coeffs: [
                BigInt("1250ebd871fc0a92a7b2d83168d0d727272d441befa15c503dd8e90ce98db3e7b6d194f60839c508a84305aaca1789b6", radix: 16)!,
                BigInt("089a1c5b46e5110b86750ec6a532348868a84045483c92b7af5af689452eafabf1a8943e50439f1d59882a98eaa0170f", radix: 16)!,
                BigInt("1368bb445c7c2d209703f239689ce34c0378a68e72a6b3b216da0e22a5031b54ddff57309396b38c881c4c849ec23e87", radix: 16)!,
                BigInt("193502b86edb8857c273fa075a50512937e0794e1e65a7617c90d8bd66065b1fffe51d7a579973b1315021ec3c19934f", radix: 16)!,
                BigInt("01b2f522473d171391125ba84dc4007cfbf2f8da752f7c74185203fcca589ac719c34dffbbaad8431dad1c1fb597aaa5", radix: 16)!,
                BigInt("018107154f25a764bd3c79937a45b84546da634b8f6be14a8061e55cceba478b23f7dacaa35c8ca78beae9624045b4b6", radix: 16)!,
                BigInt("19f26337d205fb469cd6bd15c3d5a04dc88784fbb3d0b2dbdea54d43b2b73f2cbb12d58386a8703e0f948226e47ee89d", radix: 16)!,
                BigInt("06fba23eb7c5af0d9f80940ca771b6ffd5857baaf222eb95a7d2809d61bfe02e1bfd1b68ff02f0b8102ae1c2d5d5ab1a", radix: 16)!,
                BigInt("11b8b424cd48bf38fcef68083b0b0ec5c81a93b330ee1a677d0d15ff7b984e8978ef48881e32fac91b93b47333e2ba57", radix: 16)!,
                BigInt("03350f55a7aefcd3c31b4fcb6ce5771cc6a0e9786ab5973320c806ad360829107ba810c5a09ffdd9be2291a0c25a99a2", radix: 16)!,
                BigInt("04c581234d086a9902249b64728ffd21a189e87935a954051c7cdba7b3872629a4fafc05066245cb9108f0242d0fe3ef", radix: 16)!,
                BigInt("0f41e58663bf08cf068672cbd01a7ec73baca4d72ca93544deff686bfd6df543d48eaa24afe47e1efde449383b676631", radix: 16)!,
            ])
        )
    }
    
    func test_should_not_degenerate() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        let p2 = try BLS.pairing(P: G1 * 2, Q: G2)
        let p3 = try BLS.pairing(P: G1, Q: G2.negated())
        XCTAssertNotEqual(p1, p2)
        XCTAssertNotEqual(p1, p3)
        XCTAssertNotEqual(p2, p3)
    }
    
    func test_G2_billinearity() throws {
        let p1 = try BLS.pairing(P: G1, Q: G2)
        let p2 = try BLS.pairing(P: G1, Q: G2 * 2)
        XCTAssertEqual(p1 * p1, p2)
    }
    
    func test_proper_pairing_composite_check() throws {
        let p1 = try BLS.pairing(P: G1 * 37, Q: G2 * 27)
        let p2 = try BLS.pairing(P: G1 * 999, Q: G2)
        XCTAssertEqual(37 * 27, 999)
        XCTAssertEqual(p1, p2)
    }
    
    func test_finalExponantiate_is_correct() throws {
        let p1 = Fp12(coeffs: [
            BigInt("0690392658038414015999440694435086329841032295415825549843130960252222448232974816207293269712691075396080336239827", radix: 10)!,
            BigInt("1673244384695948045466836192250093912021245353707563547917201356526057153141766171738038843400145227470982267854187", radix: 10)!,
            BigInt("2521701268183363687370344286906817113258663667920912959304741393298699171323721428784215127759799558353547063603791", radix: 10)!,
            BigInt("3390741958986800271255412688995304356725465880212612704138250878957654428361390902500149993094444529404319700338173", radix: 10)!,
            BigInt("2937610222696584007500949263676832694169290902527467459057239718838706247113927802450975619528632522479509319939064", radix: 10)!,
            BigInt("1041774303946777132837448067285334026888352159489566377408630813368450973018459091749907377030858960140758778772908", radix: 10)!,
            BigInt("3864799331679524425952286895114884847547051478975342624231897335512502423735668201254948484826445296416036052803892", radix: 10)!,
            BigInt("3824221261758382083252395717303526902028176893529557070611185581959805652254106523709848773658607700988378551642979", radix: 10)!,
            BigInt("3323164764111867304984970151558732202678135525250230081908783488276670159769559857016787572497867551292231024927968", radix: 10)!,
            BigInt("1011304421692205285006791165988839444878224012950060115964565336021949568250312574884591704110914940911299353851697", radix: 10)!,
            BigInt("2263326825947267463771741379953930448565128050766360539694662323032637428903113943692772437175107441778689006777591", radix: 10)!,
            BigInt("2975309739982292949472410540684863862532494446476557866806093059134361887381947558323102825622690771432446161524562", radix: 10)!,
        ])
        let exponentiated = try p1.finalExponentiate()
        let expected = Fp12(coeffs: [
            BigInt("09d72c189ba2fd4b09b63da857f321b791b45f8ec589858bc6d41c8f4eb05244ad7a22aea1119a958d890a19f6caceda", radix: 16)!,
            BigInt("153f579b44547ee81c5d1603571b4776a065e86b4e3da0bba32afedafcca10f0a40005e63c9408785761da689b4b7338", radix: 16)!,
            BigInt("00bb1efcca23009c3638ae9ec0ee5153fa94b4edca88c3438029bcd5909e838da44483f0bfb5877609dace3bfa7d4ff3", radix: 16)!,
            BigInt("0c0e22bf2d593bc5b7ce484f3ff81a23a0c36725909225c1cf2f277482144951ea3fe425d2a56a91b681e11abc56c7fa", radix: 16)!,
            BigInt("12c99e5152ab314ca6baec31cddbeff18acdac3a91c0e62de63e029bee76d775e0940408447b0fddad84b8dde9b86dee", radix: 16)!,
            BigInt("0fe6a726b7d4947bb7bcb22a06dd4a283ce7113e956bcbb0294883046944312a72536fff08166adcfa08dfd65e4c157f", radix: 16)!,
            BigInt("176bfe03f017f18f7a2af0f178b5f018434ef3623da77e40d7fc78fca08299f81f6879c69026f4a7ba639463893e0708", radix: 16)!,
            BigInt("0282d90ee23efd9a2e0d51af8a2048bbda4517a90a24318a75d0dd6addc29b068d17e7c89a04da84b142996aa29b1516", radix: 16)!,
            BigInt("0c2cdf5de0889c4b55752cf839e61a81feaebf97a812c7581c8f66395868b582cbea067c9d435dabb5722913da709bff", radix: 16)!,
            BigInt("0741ece37d164288d7a590b3d31d9e6f26ce0797f1b99a77cd0b5eba24eae26afcb8b69f39af06e701ceaabf94c3db5e", radix: 16)!,
            BigInt("00c9dea49cc3e1c8be938f707bbb0239e8f960fa46617877f90b3212fc3f5890999082b9c2262c8543a278136f34b5db", radix: 16)!,
            BigInt("08f574e635870b8f4ad8c18d162055ab6136db296ad5f25151244e3b1ce0d81389b9d1752a46af018e8fb1ac01b683e1", radix: 16)!,
        ])
        XCTAssertEqual(exponentiated, expected)
    }

}

