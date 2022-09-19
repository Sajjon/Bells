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

func secureRandomBytes(byteCount: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: byteCount)
    let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    
    guard result == errSecSuccess else {
        fatalError("Problem generating random bytes")
    }
    
    return bytes
}

extension Fp {
    static func random() -> Self {
        Self.init(value: .random(byteCount: 48))
    }
}
extension BigInt {
    
    static func random(byteCount: Int = 48) -> Self {
        let uintByteCount = Word.bitWidth / 8
        precondition(byteCount.isMultiple(of:  uintByteCount))
        let bytes = secureRandomBytes(byteCount: byteCount)
        return Self(bytes: bytes)
    }
    
    init(bytes: [UInt8]) {
        let uintByteCount = Word.bitWidth / 8
        precondition(bytes.count.isMultiple(of:  uintByteCount))
        
        let words: [Word] = bytes.chunks(ofCount: uintByteCount).map { chunk in
            chunk.withUnsafeBytes {
                $0.load(as: Word.self)
            }
        }
        self.init(words: words)
    }
}






extension BigInt: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            let bytes = (0..<48).map { _ in composer.generate(using: UInt8.arbitrary) }
            return Self(bytes: bytes)
        }
    }
}

extension Fp: Arbitrary {
    public static var arbitrary: Gen<Self> {
        .compose { composer in
            let value = composer.generate(using: BigInt.arbitrary)
            return Self.init(value: value)
        }
    }
}

final class FpTests: XCTestCase {
    
    
    func test_fp_equality() {
        property("Fp Equality is Reflexive") <- forAll { (a: Fp) in
            a == a
        }
    }
    
    
    func test_fp_inequality() {
        XCTAssert(fileCheckOutput(withPrefixes: ["INEQUALITY"]) {
            // INEQUALITY: *** Passed 100 tests
            // INEQUALITY-NEXT: .
            property("Fp inequality") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    (a != b)
                }
            }
        })
        
    }
    
    func test_fp_addition() {
        XCTAssert(fileCheckOutput(withPrefixes: ["ADDITION_COMMUTATIVITY"]) {
            // ADDITION_COMMUTATIVITY: *** Passed 100 tests
            // ADDITION_COMMUTATIVITY-NEXT: .
            property("commutativity") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    (a + b) == (b + a)
                }
            }
        })
        
        XCTAssert(fileCheckOutput(withPrefixes: ["ADDITION_ASSOCIATIVITY"]) {
            // ADDITION_ASSOCIATIVITY: *** Passed 100 tests
            // ADDITION_ASSOCIATIVITY-NEXT: .
            property("associativity") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    exists { (c: Fp) in
                        (a + (b + c)) == ((a + b) + c)
                    }
                }
            }
        })
        
        
        property("identity") <- forAll { (a: Fp) in
            (a + Fp.zero) == a
        }
    }
    
    func test_fp_subtraction() {
        
        property("identity") <- forAll { (a: Fp) in
            (a - Fp.zero) == a
        }
        
        property("a - a == 0") <- forAll { (a: Fp) in
            (a - a) == Fp.zero
        }
    }
    
    func test_fp_negated_equality() {
        XCTAssert(fileCheckOutput(withPrefixes: ["NEGATED_EQUALITY"]) {
            // NEGATED_EQUALITY: *** Passed 100 tests
            // NEGATED_EQUALITY-NEXT: .
            property("negated_eq") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    (Fp.zero - a == a.negated())
                    ^&&^
                    ((a - b) == (a + b.negated()))
                    ^&&^
                    ((a - b) == (a + b * Fp.one.negated()))
                }
            }
        })
    }
    
    func test_fp_negated() {
        property("a.negated == 0-a") <- forAll { (a: Fp) in
            a.negated() == (Fp.zero - a)
        }
        property("a.negated == a * 1.negated") <- forAll { (a: Fp) in
            a.negated() == (a * Fp.one.negated())
        }
    }
    
    func test_multiplication() {
        XCTAssert(fileCheckOutput(withPrefixes: ["MULTIPLICATION_COMMUTATIVITY"]) {
            // MULTIPLICATION_COMMUTATIVITY: *** Passed 100 tests
            // MULTIPLICATION_COMMUTATIVITY-NEXT: .
            property("commutativity") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    (a * b) == (b * a)
                }
            }
        })
        
        XCTAssert(fileCheckOutput(withPrefixes: ["MULTIPLICATION_ASSOCIATIVITY"]) {
            // MULTIPLICATION_ASSOCIATIVITY: *** Passed 100 tests
            // MULTIPLICATION_ASSOCIATIVITY-NEXT: .
            property("associativity") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    exists { (c: Fp) in
                        (a * (b * c)) == ((a * b) * c)
                    }
                }
            }
        })
        
        
        XCTAssert(fileCheckOutput(withPrefixes: ["MULTIPLICATION_DISTRIBUTIVITY"]) {
            // MULTIPLICATION_DISTRIBUTIVITY: *** Passed 100 tests
            // MULTIPLICATION_DISTRIBUTIVITY-NEXT: .
            property("distributivity") <- forAll { (a: Fp) in
                exists { (b: Fp) in
                    exists { (c: Fp) in
                        (a * (b + c)) == ((a * b) + (a * c))
                    }
                }
            }
        })
        
        property("add equality") <- forAll { (a: Fp) in
            (a * Fp.zero) == Fp.zero
            ^&&^
            (a * Fp(value: 0)) == Fp.zero
            ^&&^
            (a * Fp.one) == a
            ^&&^
            (a * Fp(value: 1)) == a
            ^&&^
            (a * Fp(value: 2)) == (a + a)
            ^&&^
            (a * Fp(value: 3)) == (a + a + a)
            ^&&^
            (a * Fp(value: 4)) == (a + a + a + a)
        }
    }
    
    func test_fp_square() throws {
        property("square equality") <- forAll { (a: Fp) in
            (try a.squared()) == (a * a)
        }
    }
    
    func test_fp_pow_eq() throws {
        property("pow equality") <- forAll { (a: Fp) in
            (try a.pow(n: 0) == Fp.one)
            ^&&^
            (try a.pow(n: 1) == a)
            ^&&^
            (try a.pow(n: 2) == (a * a))
            ^&&^
            (try a.pow(n: 3) == (a * a * a))
            
        }
    }
    
    func test_fp_sqrt() throws {
        let sqr1 = Fp(value: BigInt("300855555557", radix: 10)!)
        let sqrt = try XCTUnwrap(sqr1.sqrt())
        XCTAssertEqual(
            String(sqrt.value, radix: 10),
            "364533921369419647282142659217537440628656909375169620464770009670699095647614890229414882377952296797827799113624"
        )
        XCTAssertNil(Fp(value: BigInt("72057594037927816", radix: 10)!).sqrt())
    }
    
    
    /*

       describe('div', () => {
         it('division by one equality', () => {
           fc.assert(
             fc.property(fc.bigInt(1n, Fp.ORDER - 1n), (num) => {
               const a = new Fp(num);
               expect(a.div(Fp.ONE)).toEqual(a);
               expect(a.div(a)).toEqual(Fp.ONE);
             })
           );
         });
         it('division by zero equality', () => {
           fc.assert(
             fc.property(FC_BIGINT, (num) => {
               const a = new Fp(num);
               expect(Fp.ZERO.div(a)).toEqual(Fp.ZERO);
             })
           );
         });
         it('division distributivity', () => {
           fc.assert(
             fc.property(FC_BIGINT, FC_BIGINT, FC_BIGINT, (num1, num2, num3) => {
               const a = new Fp(num1);
               const b = new Fp(num2);
               const c = new Fp(num3);
               expect(a.add(b).div(c)).toEqual(a.div(c).add(b.div(c)));
             })
           );
         });
         it('division and multiplication equality', () => {
           fc.assert(
             fc.property(FC_BIGINT, FC_BIGINT, (num1, num2) => {
               const a = new Fp(num1);
               const b = new Fp(num2);
               expect(a.div(b)).toEqual(a.multiply(b.invert()));
             })
           );
         });
       })
     });

     */
}
