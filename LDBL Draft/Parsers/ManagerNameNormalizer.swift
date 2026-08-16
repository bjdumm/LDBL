import Foundation


struct ManagerNameNormalizer {

    static func normalize(_ name: String) -> String {

        let cleaned = name
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch cleaned.lowercased() {

        case "brando":
            return "Brandon"

        case "andy":
            return "Hancharik"

        default:
            return cleaned
        }
    }
}
