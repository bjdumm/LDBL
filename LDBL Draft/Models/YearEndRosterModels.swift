import Foundation

struct YearEndRosterSeason: Identifiable {
    var id: Int { year }

    let year: Int
    let managers: [YearEndRosterManager]
}


struct YearEndRosterManager: Identifiable {
    var id: String { manager }

    let manager: String
    let draftPicks: [YearEndRosterPlayer]
    let acquiredPlayers: [YearEndRosterAcquiredPlayer]

    // Keeps any older code source-compatible.
    var yearEndAdditions: [String] {
        acquiredPlayers.map(\.player)
    }
}


struct YearEndRosterPlayer: Identifiable {
    var id: String {
        "\(round)-\(player)"
    }

    let round: Int
    let player: String

    // Spreadsheet formatting
    let isKeeper: Bool
    let isRemoved: Bool
}


struct YearEndRosterAcquiredPlayer: Identifiable {
    var id: String {
        player
    }

    let player: String

    // Spreadsheet formatting
    let isKeeper: Bool
    let isRemoved: Bool
}
