import Testing
@testable import MnemonicID

@Suite("MnemonicIDVendor")
struct MnemonicIDVendorTests {

    @Test func defaultWordListIsSubstantial() {
        #expect(defaultWordList.count >= 7_000)
    }

    @Test func allDefaultWordsAreEightCharsOrFewer() {
        #expect(defaultWordList.allSatisfy { $0.count <= 8 })
    }

    @Test func createIDReturnsCorrectTermCount() {
        let vendor = MnemonicIDVendor(termsPerID: 2)
        let id = vendor.createID()
        #expect(id.split(separator: "-").count == 2)
    }

    @Test func createIDWithSingleTerm() {
        let vendor = MnemonicIDVendor(termsPerID: 1)
        let id = vendor.createID()
        #expect(!id.contains("-"))
        #expect(defaultWordList.contains(id))
    }

    @Test func createIDWithThreeTerms() {
        let vendor = MnemonicIDVendor(termsPerID: 3)
        #expect(vendor.createID().split(separator: "-").count == 3)
    }

    @Test func createIDWithPrefixIncludesPrefix() throws {
        var vendor = MnemonicIDVendor(termsPerID: 2)
        vendor.register(Int.self, prefix: "INT")
        let id = try vendor.createIDWithPrefix(Int.self)
        #expect(id.hasPrefix("INT:"))
    }

    @Test func createIDWithPrefixThrowsForUnregisteredType() {
        let vendor = MnemonicIDVendor(termsPerID: 2)
        #expect(throws: MnemonicIDError.self) {
            try vendor.createIDWithPrefix(Int.self)
        }
    }

    @Test func removePrefixStripsPrefix() {
        let vendor = MnemonicIDVendor(termsPerID: 2)
        #expect(vendor.removePrefix("PMT:far-swan") == "far-swan")
    }

    @Test func removePrefixIsNoOpWithoutPrefix() {
        let vendor = MnemonicIDVendor(termsPerID: 2)
        #expect(vendor.removePrefix("far-swan") == "far-swan")
    }

    @Test func strippedPrefixedIDHasCorrectTermCount() throws {
        var vendor = MnemonicIDVendor(termsPerID: 2)
        vendor.register(String.self, prefix: "STR")
        let id = try vendor.createIDWithPrefix(String.self)
        let stripped = vendor.removePrefix(id)
        #expect(stripped.split(separator: "-").count == 2)
    }

    @Test func customWordListIsUsed() {
        let words = ["alpha", "beta", "gamma"]
        let vendor = MnemonicIDVendor(wordList: words, termsPerID: 1)
        #expect(words.contains(vendor.createID()))
    }

    @Test func adjacentTermsAreNeverEqual() {
        let vendor = MnemonicIDVendor(wordList: ["swan", "jump"], termsPerID: 6)
        for _ in 0..<200 {
            let terms = vendor.createID().split(separator: "-").map(String.init)
            for i in 1..<terms.count {
                #expect(terms[i] != terms[i - 1])
            }
        }
    }

    @Test func nonAdjacentRepeatsAreStillAllowed() {
        let vendor = MnemonicIDVendor(wordList: ["swan", "jump"], termsPerID: 3)
        var sawNonAdjacentRepeat = false
        for _ in 0..<200 {
            let terms = vendor.createID().split(separator: "-").map(String.init)
            if terms[0] == terms[2] {
                sawNonAdjacentRepeat = true
                break
            }
        }
        #expect(sawNonAdjacentRepeat)
    }

    @Test func singleWordListDoesNotHangWithMultipleTerms() {
        let vendor = MnemonicIDVendor(wordList: ["only"], termsPerID: 4)
        #expect(vendor.createID() == "only-only-only-only")
    }
}
