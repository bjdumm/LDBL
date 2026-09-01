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
    let yearEndAdditions: [String]
}

struct YearEndRosterPlayer: Identifiable {
    var id: String { "\(round)-\(player)" }
    let round: Int
    let player: String
}
