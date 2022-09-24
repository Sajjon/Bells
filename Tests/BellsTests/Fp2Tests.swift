import XCTest
@testable import Bells
import BigInt
import Security
import Algorithms
import XCTAssertBytesEqual
import SwiftCheck
#if SWIFT_PACKAGE
import FileCheck
#endif


extension BigInt {
    init(hex: String) {
        var hex = hex
        if hex.starts(with: "0x") {
            hex = String(hex.dropFirst(2))
        }
        self.init(hex, radix: 16)!
    }
}
extension Fp {
    init(hex: String) {
        self.init(value: .init(hex: hex))
    }
}
extension Fp2 {
    init(c0 c0Hex: String, c1 c1Hex: String) {
        self.init(real: .init(hex: c0Hex), imaginary: .init(hex: c1Hex))
    }
    init(c0: BigInt, c1: BigInt) {
        self.init(real: .init(value: c0), imaginary: .init(value: c1))
    }
}

final class Fp2Tests: FiniteFieldTest<Fp> {
    
    func test_inverted() throws {
        let fp2 = Fp2(
            c0: 0x8c0ed57c,
            c1: 0x8c0ed563
        )
        let inv = try fp2.inverted()
        XCTAssertEqual(inv.c0, .init(hex: "0990a4c1e582bfd21af11d192c680b77902a6407ab042c9fcea574e03f870eb764b31d443aff543b19b9141f1c418f11"))
        XCTAssertEqual(inv.c1, .init(hex: "151dddade92ab5209a591e81abaa5e02f42f44ea2371aa002b719fd135df3818efdef2a042192ba083a76413517bd36e"))
    }
    
    // Test from: https://github.com/zkcrypto/bls12_381/blob/080eaa74ec0e394377caa1ba302c8c121df08b07/src/fp2.rs#L674-L754
    func test_sqrt() throws {
        
        func doTestSqrtSquared(of fp: Fp2) throws {
            XCTAssertEqual(try fp.sqrt().squared(), fp)
        }
        
        try doTestSqrtSquared(of: "1488924004771393321054797166853618474668089414631333405711627789629391903630694737978065425271543178763948256226639*u + 784063022264861764559335808165825052288770346101304131934508881646553551234697082295473567906267937225174620141295")
        
        
        //  b = 5 , generator of the p-1 order multiplicative subgroup
        try doTestSqrtSquared(of: "0*u + 1367714067195338330005789785234579356639813143898609672616051936515282693167588605474094216909910046701175380147690")
        
        // c = 25, which is a generator of the (p - 1) / 2 order multiplicative subgroup
        try doTestSqrtSquared(of: "0*u + 25")
        
        XCTAssertThrowsError(try Fp2("2155129644831861015726826462986972654175647013268275306775721078997042729172900466542651176384766902407257452753362*u + 2796889544896299244102912275102369318775038861758288697415827248356648685135290329705805931514906495247464901062529").sqrt())
    }
    
    
    
    func test_frobenius() throws {
        let a = Fp2(
            c0: "00f8d295b2ded9dcccc649c4b9532bf3b966ce3bc2108b138b1a52e0a90f59ed11e59ea221a3b6d22d0078036923ffc7",
            c1: "012d1137b8a6a8374e464dea5bcfd41eb3f8afc0ee248cadbe203411c66fb3a5946ae52d684fa7ed977df6efcdaee0db"
        )
        
        let b = a.frobeniusMap(power: 0)
        XCTAssertEqual(a, b)
        
        let c = b.frobeniusMap(power: 1)
        XCTAssertEqual(
            c,
            Fp2(
                real: b.real,
                imaginary: .init(value: BigInt("18d400b280d93e62fcd559cbe77bd8b8b07e9bc405608611a9109e8f3041427e8a411ad149045812228109103250c9d0", radix: 16)!)
            )
        )
        
        let d = c.frobeniusMap(power: 1)
        XCTAssertEqual(d, a)
        
        XCTAssertEqual(d.frobeniusMap(power: 2), d)
    }
    
    func testManySquares() throws {
        struct Vector: Decodable {
            struct Fp2Decodable: Decodable {
                let c0: String
                let c1: String
            }
            let input: Fp2Decodable
            let squared: Fp2Decodable
        }
        let jsonDecoder = JSONDecoder()
        let manySquares = try jsonDecoder.decode([Vector].self, from: manySquaresJSON)
        func doTest(_ vector: Vector) throws {
            let input = Fp2(c0: vector.input.c0, c1: vector.input.c1)
            let expectedSquare = Fp2(c0: vector.squared.c0, c1: vector.squared.c1)
            let squared = input.squared()
            XCTAssertEqual(squared, expectedSquare)
        }
        try manySquares.forEach(doTest)
    }
    
}

extension Fp2: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            Self(
                real: composer.generate(using: Fp.arbitrary),
                imaginary: composer.generate(using: Fp.arbitrary)
            )
        }
    }
}

let manySquaresJSON = """
[
    {
        "input":
        {
            "c0": "0x125b29d7f42b0ef0ffff8649079ce4301f65266331f13a7cb9cb35f343a8d8a1e3da5000e8365bca76766b456c6b5f9f",
            "c1": "0x199451163902fd0c1af3a601f9705303ceec56c8af1c53bbd8f1f14a31f2e98ba6dec5bc768bd1f9762d24d3aa76f282"
        },
        "squared":
        {
            "c0": "0x11b0e854cef5fb9d4de4bd5ff54d583f13fea7b72e1d9b98439bd46cbe0cbb12d233832248f045ee5b58c8b0a07d3e73",
            "c1": "0x10289f516cc7da4b6ce297ad8b7e6b75e7cffdc81afee22ce23aabcfd2c5451b53a0ece27e67179253c7332b8e8c994a"
        }
    },
    {
        "input":
        {
            "c0": "0x0a6a0b851b266a9b7f1636836e7445b4e4c94f42c92a13e974602f2719332fdb2ea757cc0faa38b57344935801aa0fce",
            "c1": "0x07daff5bd9b884dbdbe39819f6124b6480a00984ed28c197b466d641a63216be9aeafd42f0ab2d68006e6b74c539c5d6"
        },
        "squared":
        {
            "c0": "0x198d431d9baae37eaf90bcbf751e6817b7d55c78192381750818f2606e84bfb9e99bba633c9aef86b932254899bec67e",
            "c1": "0x1693a3ccb344d83b6e1b615ba5e708b924a2768f3fb8a1d9bf1ca380e0efa7065c349edf2380a55815733e8d6dc9f200"
        }
    },
    {
        "input":
        {
            "c0": "0x018c3abd4cfe59385f2d9e5071f8cd0c78a3d53f2ff350e80f478a58cd88cf90304f95f4d8e8b165c6a253000deaaf8f",
            "c1": "0x088f07677ad2c3cace7a1bda31a207be1a21e56822e23c41f3e36ce994a298a406702d7fcf96b109863a008e8046d8f6"
        },
        "squared":
        {
            "c0": "0x17793959fbe1bcffd64156538b6b1ecda43cb9f03fb693c6945009e1f14b0f5d7b3723e4e2e9e0efb8207de9fd74785e",
            "c1": "0x02ddca8c756202a2afb03e3348fd7d20ecc9ffcfc5b9cc9216f81d12b5c648245c3f8872af3573a4abcdb682f4ec7959"
        }
    },
    {
        "input":
        {
            "c0": "0x1871b579eac24957adf843bd6f19f704a8422cbd95ef8d6ac5d6f5169d64b363ca129c197b14829f9175c1ea3f79cf48",
            "c1": "0x16c2cf95b3f75a0f223d3bc4a17d5e7f7b0bf0a99299eeaf7f40f777de2d4251aafa54c6d7d72350a101cd8b4a56351d"
        },
        "squared":
        {
            "c0": "0x1245e235dd1a79dc1cbbb963d68f28922e49d17a081189391688b561c1ba0686b6067010d7999206299058ac38b11b2e",
            "c1": "0x17fc5f25be205a22f2c18e3ad02b2bcab894063b0fdcae71187c5596393ce59a46e1cf92ed05bf2b5c85c015afc61198"
        }
    },
    {
        "input":
        {
            "c0": "0x12617637c993d31c073e91644da6358295baf6c39758df2779a3d030c818316509112b3429a858aab515050103ba23fa",
            "c1": "0x0416d918f7c20bc14631a5716b0e01f465eca43f471e270fec585fb3796603ce52f2ada93a913f6981e51e890a31ee5c"
        },
        "squared":
        {
            "c0": "0x0327d82f685594dbf5c86408340bfdcf5b501356a8cb27267603ea66eea1cbf96031bafe30ce04b870f86b770f6b828c",
            "c1": "0x135b1885bd900ad2696206cea30e8f67c7cd1b7538e3248c63d3b6347d1a7e589b2afa56043d8ee5ee57281a1719d08d"
        }
    },
    {
        "input":
        {
            "c0": "0x07b1f7d2c60184364604cc1b36d3bf5fe41d2bb0361a9bdabf82366155a58c9a8b58153beee0a0f6732f53dbc47f5e2c",
            "c1": "0x07959766b047fad5e86ed07b413f622c81e55b6a44515518d1a46c37299549d9c055672026c383a8a523b607abc0ce2d"
        },
        "squared":
        {
            "c0": "0x0ba6d8781a10add21586fecb3c1986cf9946b13ddeebe13da3bd0ad0fb4db0cc584f8051c0930075789df9a0dad278df",
            "c1": "0x0dcaf97aa317cf9407ce5bc64e672b146b7c7b583464e92a55fa832443744b3d8d76b9890eaecec05b8f295386b775a7"
        }
    },
    {
        "input":
        {
            "c0": "0x14dbf97e76350d68f343eca1faf1a14374fa0188d5b5f9042362d9c658313aba19e0aa671f2caf6a0856b65673af5bfd",
            "c1": "0x05f1343ea98bb3c558f41c52411c4bacff5b94e972a83816e032142a0ca275a714470c628c36af525c556c9fc57415a4"
        },
        "squared":
        {
            "c0": "0x17f7911c0d9b7df0d7c764620d06ba384ce5b5723986d34ff5fc784e9255179cb3310fa66787996760ae57b273b65775",
            "c1": "0x0a817c907241c573ab47ebc555cb916c3c7e9d1faf6d538c0d718fbb2306c0d47878e751b76eea34129fdf673d50a1e9"
        }
    },
    {
        "input":
        {
            "c0": "0x197fef29988b6e59f6b6126267fa2dee8e55a8a5d5690bc774994040fe1125998499792c77da6eb105ab55c8528e6a2a",
            "c1": "0x02288a3530bfbac115259834bec3efb2f6d736a48cec8b0e7a1de6d48b4983d0bff20d80123dded06640fb84609a4306"
        },
        "squared":
        {
            "c0": "0x1898175653e9eb1437885d8666c06c1712d720962421cfe0024e722dc610a15c431e48c9e13136ac78b6d20c29edb541",
            "c1": "0x1806fa78cadd92986e677ab1c1a86ff5d4feccccc919545c73d583270fd7bb36b70a3169960c23613e4494e37afe2f1d"
        }
    },
    {
        "input":
        {
            "c0": "0x0eab6c79ccdb5c1ed061b961c43913a1ce17decc1cb496647c5a98b9b043e75fea90ceae37c7e9d33c9615286133776e",
            "c1": "0x0b097dac0f0dabf8a1b08e43d5969f0264a9b3c5d5fdc325e48041a5715cf7207f14285b47353afd7e2d57a1a0cc4f7e"
        },
        "squared":
        {
            "c0": "0x18cab3ede2cc0951063ff3ad162fd1ecba847e10b529ea7864e75e4ba60b623d696022bf01486d246e92dcde665047c5",
            "c1": "0x05d6912b4e0b01f63c94f29c756617f929a8a5dc21ce33c763208d7d198da5dd7957977a61d5d23ea9bf245fe41eab50"
        }
    },
    {
        "input":
        {
            "c0": "0x0214452deee536659164d48b4914a7bfccd8860e94c86a437220764b82ae1b3c44382f076bb2e5c051d557a7472f1d54",
            "c1": "0x03e4a2df6e53dd9881281c4f5fb82687c06d2f1143b3f172739bc297c5f130590931177af59ba414353c19725515be7d"
        },
        "squared":
        {
            "c0": "0x0e6b18770013165454f08477b41272b79226ad021e613407736c7287ba85ebc4567b21ce71037e0716b8c3813fbf16b1",
            "c1": "0x0219cda5a872473571c7fbe82a64909856234c9c73e5234ff83037ea9159cac6757d058ecba44cd2f2b2b138d4b2bb2b"
        }
    },
    {
        "input":
        {
            "c0": "0x09f4f822304c15122e53ee81a0d84a7992ac0cf39d98d4de4881ddd70813ded3cc555b05fb37e8bc1a855ab6eda82c0b",
            "c1": "0x0747a060356f9af43e31df363cc1d12fadd2cc14284c7da73760fe66958b3f0102acf18514d17f903117e2d7f0d7923c"
        },
        "squared":
        {
            "c0": "0x17a6ba588dee8e0a8514b96366a1abc3b1608f20918b47ddf2196ad16043177eccf59e745ab3d37e0c97381b30ed5984",
            "c1": "0x11a5b75c0c2ad631beab3a9d3eec91896186b1547ae0122b6ccfb695bf087a1d7a0f489504a7c1c9a1ed05fafbfc96f1"
        }
    },
    {
        "input":
        {
            "c0": "0x0a67eb028327cae11afc3f0a16c5fffd9a709feb15d42eb70a827dcb944c2ebee69dd4524f0e8ccd2e6f67cb71c1e602",
            "c1": "0x102a02c6ab4fd01de67a66645a9dd201f23206477dce0e8547fc2ec3fbf16ccc5c3b95bd93b0b5e1cb423cc9d2cdd00d"
        },
        "squared":
        {
            "c0": "0x154c3353f7ceb5af6e513d2a3249d5a49e58e82d01fb22324740a7c8e0eeb7bd04102a927dd5c286c5f0df6408574fb8",
            "c1": "0x10c655751d45502d0b596b5e470bf8ed38df8c9e6c6809c5fb605b08f8b53dceaf183c66a884e3b5a76eec322ac28fe8"
        }
    },
    {
        "input":
        {
            "c0": "0x0738cac2b484a0fb4509203895e044b5028479b256de133c0e9257faf96eec6a648ce00389609ea96e1735b86635379e",
            "c1": "0x16dc88e692d081141f40d692600f2983f3c946c73368f4fae2ed54a9dcf62e0ed1b8aad2e40f861a9b86fea7c9e30efa"
        },
        "squared":
        {
            "c0": "0x08f0422f8b52c1dcda119dd58c0661e0493d92d095253fab188eb39f4a282eca7c7e7ef719e30bd49183545ec360b1fa",
            "c1": "0x09a61f1b3df17b6ea5da6e23ed05edcf6e756d0bfab9261db4f693d35875391f73082fcac20c49549f96036f69bd4ae3"
        }
    },
    {
        "input":
        {
            "c0": "0x04be2a99e45d15c960e686aab3ba43604508cc3d55358354b5818e11a349fe3bce6b405ae107d61a55b2fa0194a93bd8",
            "c1": "0x123a1c14a679dad9a810a8e066cb1fd09fc59147ef3aba787d11d2fa37872fcd6c297a90704edeb56d268bc64ee44073"
        },
        "squared":
        {
            "c0": "0x0a8c92b64fd88dad325c9a69b45d54ee9427ff3468930b20a92899016e5a47c71862eeb9625af7aa4499eb142f2c68bd",
            "c1": "0x0dde03bdf7761fe5e02218a1adf4244c8dcc568514a5f4f642e2955fcec2c3e65ab2b771f0153122a5b96ad43fe89b1d"
        }
    },
    {
        "input":
        {
            "c0": "0x0c4aef22109530e91a8ee63a26d1bd62830e32e28694ce00860af3cbd521976928c99551f868087b4d23ef195f7e0474",
            "c1": "0x10034a1f6ef38142aa7d63083e42ae8c691cbd0e0a955bd06647e50efc619c64ae0ed909dee6203d7d9d3f349eceaff3"
        },
        "squared":
        {
            "c0": "0x170be6e93e5d25d8db5149782f53dfa46caa37df4a67ea799c4e75c0eb32900927a092a4f800914d35056e12f21becd1",
            "c1": "0x04bcefa0888db1a032801f6cc35f3e2defc5c07f232c40673754f3186d84660e7edbad49ab97a07f70e553d1035d860d"
        }
    },
    {
        "input":
        {
            "c0": "0x0e34f49270b0d5b70230198fe3ced76c28e20a883fed57fab2f283a72788851c54a61defcbc71ceb87157dd3d36c26d4",
            "c1": "0x16e1f7b3c5f826ea26caca47b22061b37557a5c96b2d4a8e5c87f8e4445922f1983e2f617554fafef15a0da56713839a"
        },
        "squared":
        {
            "c0": "0x073b0e307eeaa6a861746771d1b0cb01562ebc9250fe159e9b0fd00340bb3561a344144f2018c21132b58aaef11c65d2",
            "c1": "0x033efe74b6711994c8995b34f14d77153cf99686ff69980b4c0c73f6a29063e901ecba2ed6a6ddb0633f09388b04d004"
        }
    },
    {
        "input":
        {
            "c0": "0x0240ed17bd4adbd5a2214eb89f801bfea988641da6ae1d5bd387b5120ea7b6456be5d1c3c150fea55faff05436c61784",
            "c1": "0x165fa760882c6efc951986af4efcf24490039395ebc90b2fcec13400c37c25b75d22028663555ed6c7fcaf524aef7663"
        },
        "squared":
        {
            "c0": "0x16d90e5065cd0c9932472665320d381191a006bd9a926692da6df9ea56734ca7cb0a083d2e70a18ec6b40ee7e1e0614d",
            "c1": "0x0a64fc805acc549b77b4db73bdbbbed4ac23e35d442a34037774220434da83ec26391fd12cdd0343bbf8ebe9cc85b483"
        }
    },
    {
        "input":
        {
            "c0": "0x10f396fd4232a3c649b82f539c3684170cbae24bb520ed3f7ced2fa560487a3561f7963308a919451498b4294ab1cee3",
            "c1": "0x104c5f38e502057c9725b32d21c5c15c2c2e90b945d18c33ebc0aaeb589a1e58861a3ec228482c623bac4c82cb114edb"
        },
        "squared":
        {
            "c0": "0x0da62e36847844ca59d05eb0c825bc8d2a0f11d4b1a6011b13c9f68e3de70757380440531e1fadf9ea894902c2a69f2d",
            "c1": "0x0759a463a0000b625aca1d248b5d0b97396a55c7c905e46dc24d76fd144fd80a470793dd169b638aa5b3a1e9fff1c002"
        }
    },
    {
        "input":
        {
            "c0": "0x1542502176e9625d28dac5afffc3c479e88cfb27ac3e37dea2429ff70037ac885737d4cb2f13444000aa3eb3835cf4db",
            "c1": "0x04e0a5a997c2790a8c69ff3007de3de5ef33d88b013daf2c455f16cdbb37cbd1869c36b5da23cacbec3bbd326dd80f0e"
        },
        "squared":
        {
            "c0": "0x0e9c024af1df99404dabe07418f2cb5cb72b826245ee439ae15f509b9c681b3924ca7bd1a318f98bcd80895472cbb937",
            "c1": "0x0f8c9ce8ef73b65846dc80c4a4ee0bf97015753e04a6c92a1530b7e2e968fa1b10349a7a5d815ce29dbbe6040b20730b"
        }
    },
    {
        "input":
        {
            "c0": "0x051ae66940046ca15a1e6f2cfbe9a166d0d43702842be703a75d98dd1b9a0e1dc6ba4870738e081b075db236f60b5ebc",
            "c1": "0x166bd1923fff6880e91c70d8f11a9f51455ad770ec5c40c3f99f75f3fa64809a4c47e153f70527e31328da6d459cacbb"
        },
        "squared":
        {
            "c0": "0x04c0db911a8e2820366622fe2bf2c83bcd143b2d30fb1fcb2949c0703788080a869ad31ddbee101ebf6f8ec09e7795e4",
            "c1": "0x0220fa3d5db2ef746051524a7bbbfaab6a7d2cd4a444dd46fb51b8c649ec787ba1c91d4e81a4d323335e56684a5b847e"
        }
    },
    {
        "input":
        {
            "c0": "0x057f12e07ac0cdbd1b0abc57c235e8be9cf510933980dfed115da3742b35a645e0c79f86658d65d83a3fa9283833716a",
            "c1": "0x17177240df31fac3e9dfc05d01079e0cc8db1f650b164c24ea4257690a79e54989404788a612b872e6682050d84752c7"
        },
        "squared":
        {
            "c0": "0x10256c3c3676a8a40c5c77bc1cf6d07d462c115dd0f6ef4550db82c722987b0d4cd277cf5e8adcc25a42aca04303054e",
            "c1": "0x1485f87dd5991ef4093fcd613ce8da288707ac758c127dfe6f3336837c625b7b7931b8f926787b468aa38f0736175ac2"
        }
    },
    {
        "input":
        {
            "c0": "0x167e686fa26d0835a4853eba072dbd02c5840f1bbe0636f6b555888a46abe07929514d27179ac73226731a461a7ba7e0",
            "c1": "0x10a2b210a443c02e4d3133e7ce0d839c569498dc2e381512f9e4c95b0cd60b5df540da302601436d301beca3a82845fc"
        },
        "squared":
        {
            "c0": "0x05b92172a3f4434c77d95db4ddeb1b1b87beecf89994c18e439b8b080066f828461ca24fcc276694188f8fda662e74c3",
            "c1": "0x0970d1414cff378148af8be1d22daa06d4651e4a45c5d5585b2454419655fa0e3756d11e75ea27d919f07e057b8aa7d9"
        }
    },
    {
        "input":
        {
            "c0": "0x0d21c914b927997209786c258fe22999651d247bcacd8b643b5c4379faeec71ed151f3dffa0751ce5ac3cfb0502baac5",
            "c1": "0x037e74d5254a919dd4726cb4965913cf7848facbd4502d69f7dc76dfee04e3256d09f865a7b93bd38513a5566b25498e"
        },
        "squared":
        {
            "c0": "0x0e17f6e4ae6bde23e57e513611fc7666a44b4e17d9da87a0c1e300783c48540f03fd77b3f515e2aa51a4a14f9c194126",
            "c1": "0x0b1a33c490c7413987fcfe273d0226ae6c9a6550908e4f0bd48465eba83c81e8be31ab0e4f18b1511c3816ab00713dc1"
        }
    },
    {
        "input":
        {
            "c0": "0x0a9be480bccc35ee3a1fc8e00c49c5050a21da51a19a5145dab8d06e5d9e6c90df21c8ef36615a8bdb5a4f60a47ec07d",
            "c1": "0x01bf8d9b9405fb7244fa9a050ad508937d8750ca96209ce1543a7fc330b8119050c5541a911cd1585c8926b714966fe0"
        },
        "squared":
        {
            "c0": "0x133c2fea4c53a99f23185f190857bcfc96371b820e2f26e9968cd5cf921411c1af6a658ba1fa843505ea1fb117327392",
            "c1": "0x133e3d0996d0627cb4ced604eec36fc36413b523e6a83cfba3a6dc17f57875fe5ec1e97146820602ddbf58ecdd6ce848"
        }
    },
    {
        "input":
        {
            "c0": "0x16a6b59c675ebd57a4de10cb6f1985d36506efef16867998c49ca8ea0ec77c0a03c4a1edc396154abd54c903efc12914",
            "c1": "0x1180e2fa373aa0ec2e6b358543f9c87f662d79903d29d09d70119a4cce33f3e9a89ccf68312c11bce50002f9a8d6fe18"
        },
        "squared":
        {
            "c0": "0x15c22d0ce04f65b8c9268808aa57ecbd6d4d55e16c54673a1e04e074d7cce0b1758dff239baae26ac3944683b2314ef2",
            "c1": "0x048de9a9f5d9a5272c6d570bd9a831a60bc0faf86676548f2199f7770439d57a42d61dec06e59962f44f7cbfc5dd66f9"
        }
    },
    {
        "input":
        {
            "c0": "0x030a79d5e6a1e0af1ee68bb0a17ad2d0cd4d003603e67bfdc7d77c16d682846195f2db46c700980bf81eb9372ab1c938",
            "c1": "0x1225acb14939bbf067812f1956a21b2fd05544d4dd6a8febae299684b35a44262a47e14e0898bf78a979498e3fd7648f"
        },
        "squared":
        {
            "c0": "0x09dc9c3c19ba28caa4f2597d31f54b4c01ef721fa3b0d4c0c55d3d146a4f9acb82071421fb293a4150d8b31b090e5be6",
            "c1": "0x0326f6db9c01da9062c952adaf4fedf696a6dfc28aa1f3fe83d5ccde9a7bb1e9ac7fdfa8bd28c2b2255cc4eb050e4616"
        }
    },
    {
        "input":
        {
            "c0": "0x19b5b8f451debbd37cb56126b0a7b9e8d651fc9987613b577aaa0cedf6fcd91fdb83b1ac264701c4e593a8f36eec5d0f",
            "c1": "0x0cf146406a0c330d6bab7539aebb8a88087b24a3b9a966f80ebf11487969f3bbbcd0673a97da92c5b9c53f8ace623f12"
        },
        "squared":
        {
            "c0": "0x08a44d3dd47b187419619f9a1aa214163860d5d528c3653b4303dd62c20bb399fb49c7334e936adc4bb6ecaf48bb8891",
            "c1": "0x04ce09085f58bef298c7f533e0995bde1acd761574138e174a533a301c9e7139cfb8ec8a2a37aef0db29d2906f4ac718"
        }
    },
    {
        "input":
        {
            "c0": "0x09c36248b9f8120e5696d24afb463bbac9d592793870dc23d425b7c43ef4943c0b6b4f74722c03f3a96487f6cb2a6cde",
            "c1": "0x1022bc5568eaad431faf942caf37be2eb1f85f3f02ad22ba4cb13bab6c7c7723bca095d0cc67a1aac9ba7533d82247cb"
        },
        "squared":
        {
            "c0": "0x03bdb871c0ac98d081990160a8a35365f315624b6b9dfdee1c0183d9f717883603a01588c615c9449eed03b164e6fd60",
            "c1": "0x016a3541e71b6fbf154c870b9f148454d689f0eeb749539893c29e9bdaeb8ab532d6475b58125a6868069d1aa53400e0"
        }
    },
    {
        "input":
        {
            "c0": "0x183bda04c684efd81a6325c6587f5afd67f4ced67966c2ecf0e47269d9b6233183f2ac82f79916ae8ffed2f25da71629",
            "c1": "0x149dba6bf11624d2ccedbb95777f639a3c1c686bf75185f72f659d618c2d704c287c488f59e765c19a28246c813873bf"
        },
        "squared":
        {
            "c0": "0x11d2ef64c2877c732d48e5a82afc4c62f40dbb6375daf26a12846cdb4e50efc3f9feb506e3d9b07d87af95ce923425a0",
            "c1": "0x19f2b1ea09acd15babb1cd871ce20662caa78b756a78cc74552501d8b16b44025eac8c8655a3912a98a7de8fd97fa5bf"
        }
    },
    {
        "input":
        {
            "c0": "0x043cb5a9f16249e0bcb98cc01ded15a79d44284611d8802d4142fef85b8013d0f2c0d2fd260f2552988a07977477b802",
            "c1": "0x170bfd02e72827412957eae82c53d2be7cbabad647f4f23a02302a06ccae3c8863576b710483b056ff191e9e4fefdbf3"
        },
        "squared":
        {
            "c0": "0x10946c1541effe65d94bb74778142be3950d2e014774defb917986516d8724d6c7ac2bdbe80f828c1c8296775c0cc81e",
            "c1": "0x08a2a22c5ad39df217bf8c1795b5b7ee19c72f1e7db7b5876e8808645232f75fe0f29bac02e4730492ec2fdee1c96a72"
        }
    },
    {
        "input":
        {
            "c0": "0x174810ef21ec3538d6988cd9281f690223eda989c36e1615ada323223604e4596a8a9fbef66f95bd20d3ea4a3d59b6c6",
            "c1": "0x078395af386d45a8679011c2fc2baaba46abc62076a32540758ccb7a6d6d4396bc70c810f341d9ed770033f6b9853942"
        },
        "squared":
        {
            "c0": "0x09b57e5093affd83121c6ad810ad0bf3c9deba9393b8fe80bc27834baba0345a9e6d99024699718a74a2ba897be1b16f",
            "c1": "0x0ee8fcf80faefa9abc4333f550ac22d199ad7d316b72f72bf8228202c5b13208f0a461f3d3d1a972989a34a4270650cb"
        }
    },
    {
        "input":
        {
            "c0": "0x056c5638b7ce4f0cc577b9936d429d733b86c3d6fa046bac5983d4cf9d3c642b806b349663eba1d30ac24728faea1205",
            "c1": "0x1051bcdad2ded80f40f3db1345f3b87682ceaffe4bbf6c90c7ad3e83ca68f0c9515538d6dce5f70e88ee17368747be33"
        },
        "squared":
        {
            "c0": "0x15898026e837d72bd66f3c2fa78e14244d0608a51a99e1eaf411bf25f70de7e385966980a3078a1244268415410cd38e",
            "c1": "0x12591f5f63346782384c0c3fc4d908bec99710c155907028189cbe03f806a9320c3f61a1f70371c88207ad242a57c450"
        }
    }
]
""".data(using: .utf8)!
