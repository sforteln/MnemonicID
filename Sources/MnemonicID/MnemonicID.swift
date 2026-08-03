public struct MnemonicIDVendor: Sendable {
    private let wordList: [String]
    private let termsPerID: Int
    private var registeredPrefixes: [ObjectIdentifier: String] = [:]

    public init(wordList: [String] = defaultWordList, termsPerID: Int) {
        precondition(!wordList.isEmpty, "Word list must not be empty")
        precondition(termsPerID >= 1, "termsPerID must be at least 1")
        self.wordList = wordList
        self.termsPerID = termsPerID
    }

    public mutating func register<T>(_ type: T.Type, prefix: String) {
        registeredPrefixes[ObjectIdentifier(type)] = prefix
    }

    public func createID() -> String {
        var terms: [String] = []
        terms.reserveCapacity(termsPerID)
        for _ in 0..<termsPerID {
            var next = wordList.randomElement()!
            // Avoid an adjacent repeat (e.g. "swan-swan") since a doubled word reads
            // like a typo; a non-adjacent repeat ("swan-jump-swan") is still fine.
            // Skipped when the list has only one word, or every retry would loop forever.
            if wordList.count > 1 {
                while next == terms.last {
                    next = wordList.randomElement()!
                }
            }
            terms.append(next)
        }
        return terms.joined(separator: "-")
    }

    public func createIDWithPrefix<T>(_ type: T.Type) throws -> String {
        guard let prefix = registeredPrefixes[ObjectIdentifier(type)] else {
            throw MnemonicIDError.unregisteredType(String(describing: type))
        }
        return "\(prefix):\(createID())"
    }

    public func removePrefix(_ id: String) -> String {
        guard let colonIndex = id.firstIndex(of: ":") else { return id }
        return String(id[id.index(after: colonIndex)...])
    }
}

public enum MnemonicIDError: Error {
    case unregisteredType(String)
}
