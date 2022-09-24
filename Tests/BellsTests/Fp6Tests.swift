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


final class Fp6Tests: FieldTest<Fp6> {
    
    func test_inverted() throws {
        let a = Fp6(
            c0: .init(
                c0: 0x8c0ed57c,
                c1: 0x8c0ed563
            ),
            c1: .init(
                c0: 0x8c0ed562,
                c1: 0x8c0ed561
            ),
            c2: .init(
                c0: 0x8c0ed560,
                c1: 0x8c0ed567
            )
        )
        let aInv = try a.inverted()
        
        XCTAssertEqual(aInv.c0.c0.value, .init(hex: "0f5d3888ce8fb7e81051c8ab459ec57c5cac1cc5bad8d497f5d941f454303adb51e1f13856f01eb3b6e96a349bfd506c"))
        XCTAssertEqual(aInv.c0.c1.value, .init(hex: "00b5066943316367b6f802b3e2feb164112cf652c56a8fe4395f22843335c3f6db7d125937cfa97b25f59ab0a0ccae5d"))
        
        XCTAssertEqual(aInv.c1.c0.value, .init(hex: "1308087806edee690d656f71d22ae367dfc4963d04e46a2853d2e3d80c1b7494544e1cba6032f0db129086d6da4a1d61"))
        XCTAssertEqual(aInv.c1.c1.value, .init(hex: "18b68ea30cef69b18b39c24d25fff7c55b0ac9f2255e96f66d8aac1249925ad6c5f810e86dacdf69633e1b646ce82c64"))
        
        XCTAssertEqual(aInv.c2.c0.value, .init(hex: "07b1fa73b4b5c51f32ea6b76a0fa01e75c758e06983c5f6813890ef66fa9285f69c75be4c28fb6fb742f8f4cb2e91545"))
        XCTAssertEqual(aInv.c2.c1.value, .init(hex: "10fc74a9af1ceb669cf38cd6277e1cd4f7f4c10b46219aed14de3948b4b64a318f174c3b5e403449dcbc2aab5f712c57"))

        try XCTAssertEqual(a.inverted() * a, Fp6.one)
    }
    
    func test_squared() throws {
       
        let a = Fp6(
            c0: .init(
                c0: 0x8c0ed57c,
                c1: 0x8c0ed563
            ),
            c1: .init(
                c0: 0x8c0ed562,
                c1: 0x8c0ed561
            ),
            c2: .init(
                c0: 0x8c0ed560,
                c1: 0x8c0ed567
            )
        )
        
        let aa = a * a
      
        XCTAssertEqual(a.squared(), aa)
        
     
        let b = Fp6(
            c0: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed566",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed565"
            ),
            c1: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed564",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56b"
            ),
            c2: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56a",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed569"
            )
        )
        
        let c = Fp6(
            c0: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed568",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56f"
            ),
            c1: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56e",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56d"
            ),
            c2: .init(
                c0: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed56c",
                c1: "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c0ed553"
            )
        )
        XCTAssertEqual(b.squared(), b * b)
        XCTAssertEqual(c.squared(), c * c)
        XCTAssertEqual((a + b) * c.squared(), (c * c * a) + (c * c * b))

        try XCTAssertEqual(
            a.inverted() * b.inverted(),
            (a * b).inverted()
        )

        try XCTAssertEqual(a.inverted() * a, Fp6.one)
    }
    
    func test_mulby01() throws {
       
        let x = Fp2.init(
            c0: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153fffe877e1715b7a71e48",
            c1: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffff20be8b9310b1e3e4"
        )
        
        let y = Fp2.init(
            c0: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffff20be8b9310b1e3e4",
            c1: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153fffe877e1715b7a71e48"
        )
        
         let a = Fp6(
             c0: .init(
                 c0: 0x8c0ed57c,
                 c1: 0x8c0ed563
             ),
             c1: .init(
                 c0: 0x8c0ed562,
                 c1: 0x8c0ed561
             ),
             c2: .init(
                 c0: 0x8c0ed560,
                 c1: 0x8c0ed567
             )
         )
        
        let sut = a.multiplyBy01(b0: x, b1: y)
     
        XCTAssertEqual(sut.c0.c0.value, .init(hex: "000000000000000000000000000000000000000000000000000000000000000000000000fb8862bff052039f2fa36167"))
        XCTAssertEqual(sut.c0.c1.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffd0e1b5b406416505857025202"))
        
        XCTAssertEqual(sut.c1.c0.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153fff0c2b3a16d0b244011"))
        XCTAssertEqual(sut.c1.c1.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffcba433a33d261322995b89e11"))
        
        XCTAssertEqual(sut.c2.c0.value, .init(hex: "0000000000000000000000000000000000000000000000000000000000000000000000000000000430c32f0af4dd6e46"))
        XCTAssertEqual(sut.c2.c1.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffcba433a4e2975362af9dab0e9"))

    }


    
    func test_mulby1() throws {
       
        let x = Fp2.init(
            c0: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153fffe877e1715b7a71e48",
            c1: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffff20be8b9310b1e3e4"
        )
     
         let a = Fp6(
             c0: .init(
                 c0: 0x8c0ed57c,
                 c1: 0x8c0ed563
             ),
             c1: .init(
                 c0: 0x8c0ed562,
                 c1: 0x8c0ed561
             ),
             c2: .init(
                 c0: 0x8c0ed560,
                 c1: 0x8c0ed567
             )
         )
        
        let sut = a.multiplyBy1(b1: x)
     
        XCTAssertEqual(sut.c0.c0.value, .init(hex: "000000000000000000000000000000000000000000000000000000000000000000000000a7b041e8a6056338d26c8166"))
        XCTAssertEqual(sut.c0.c1.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffd61f37c316c36813d51da3b27"))
        
        XCTAssertEqual(sut.c1.c0.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffe5d7bdee8fb0226e76b3cbdac"))
        XCTAssertEqual(sut.c1.c1.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffdb5cb9d18470ef6c1349725fe"))
        
        XCTAssertEqual(sut.c2.c0.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffe5d7bdf06e998e5d8e59f722c"))
        XCTAssertEqual(sut.c2.c1.value, .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffdb5cb9d2a3c9c9ba6132e6efa"))

    }

}

extension Fp6: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            Self(
                c0: composer.generate(using: Fp2.arbitrary),
                c1: composer.generate(using: Fp2.arbitrary),
                c2: composer.generate(using: Fp2.arbitrary)
            )
        }
    }
}
