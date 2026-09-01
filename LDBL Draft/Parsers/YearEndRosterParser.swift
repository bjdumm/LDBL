import Foundation

struct YearEndRosterParser {
    static func parse(rows: [[String]], fallbackYear: Int) -> YearEndRosterSeason? {
        guard let headerIndex = rows.firstIndex(where: { row in
            value(row, 0).uppercased() == "ROUND"
        }) else { return nil }

        let header = rows[headerIndex]
        let year = rows.prefix(headerIndex + 1)
            .flatMap { $0 }
            .compactMap { Int(clean($0)) }
            .first(where: { (2000...2100).contains($0) }) ?? fallbackYear

        var managers: [YearEndRosterManager] = []

        for column in 1..<header.count {
            let rawManager = value(header, column)
            guard !rawManager.isEmpty else { continue }

            var draftPicks: [YearEndRosterPlayer] = []
            var additions: [String] = []

            for row in rows.dropFirst(headerIndex + 1) {
                let player = value(row, column)
                guard !player.isEmpty else { continue }

                if let round = Int(value(row, 0)) {
                    draftPicks.append(.init(round: round, player: player))
                } else {
                    additions.append(player)
                }
            }

            if !draftPicks.isEmpty || !additions.isEmpty {
                managers.append(.init(
                    manager: ManagerNameNormalizer.normalize(rawManager),
                    draftPicks: draftPicks.sorted { $0.round < $1.round },
                    yearEndAdditions: additions
                ))
            }
        }

        guard !managers.isEmpty else { return nil }
        return YearEndRosterSeason(year: year, managers: managers)
    }

    private static func clean(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func value(_ row: [String], _ index: Int) -> String {
        guard row.indices.contains(index) else { return "" }
        return clean(row[index])
    }
}
