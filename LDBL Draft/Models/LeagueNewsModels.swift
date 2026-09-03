import Foundation

enum LeagueNewsType: String, Codable {
    case beerGameRecord
    case beerGameEventWinner
    case beerGamesChampion
}

struct LeagueNewsItem: Identifiable, Codable, Equatable {
    let id: String
    let type: LeagueNewsType
    let title: String
    let message: String
    let player: String
    let event: String?
    let result: String?
    let year: Int
}

struct LeagueNewsRecordSnapshot: Codable, Equatable {
    let eventKey: String
    let eventName: String
    let player: String
    let year: Int
    let result: String
    let sortValue: Double
    let timed: Bool
}

struct LeagueNewsWinnerSnapshot: Codable, Equatable {
    let year: Int
    let eventKey: String
    let eventName: String
    let player: String
    let result: String
}

struct LeagueNewsChampionSnapshot: Codable, Equatable {
    let year: Int
    let player: String
    let totalPoints: Int
}

struct LeagueNewsSnapshot: Codable, Equatable {
    var records: [String: LeagueNewsRecordSnapshot]
    var eventWinners: [String: LeagueNewsWinnerSnapshot]
    var champions: [String: LeagueNewsChampionSnapshot]

    // Every Beer Games season that existed in the scoreboard,
    // regardless of whether that season was complete yet.
    //
    // This lets LeagueNewsManager distinguish:
    //
    // 2026 already existed and just became complete
    //      -> announce champion
    //
    // 2016 suddenly appeared because historical data was reloaded
    //      -> DO NOT announce champion
    var seasonYears: Set<Int>

    init(
        records: [String: LeagueNewsRecordSnapshot],
        eventWinners: [String: LeagueNewsWinnerSnapshot],
        champions: [String: LeagueNewsChampionSnapshot],
        seasonYears: Set<Int>
    ) {
        self.records = records
        self.eventWinners = eventWinners
        self.champions = champions
        self.seasonYears = seasonYears
    }

    // MARK: - Backward Compatibility

    /*
     Older installed versions of LDBL already have snapshots
     saved in UserDefaults that do not contain seasonYears.

     We don't want decoding those snapshots to fail.

     For an old snapshot, reconstruct the years that we can
     determine from the information already stored in it.
    */

    private enum CodingKeys: String, CodingKey {
        case records
        case eventWinners
        case champions
        case seasonYears
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        records = try container.decodeIfPresent(
            [String: LeagueNewsRecordSnapshot].self,
            forKey: .records
        ) ?? [:]

        eventWinners = try container.decodeIfPresent(
            [String: LeagueNewsWinnerSnapshot].self,
            forKey: .eventWinners
        ) ?? [:]

        champions = try container.decodeIfPresent(
            [String: LeagueNewsChampionSnapshot].self,
            forKey: .champions
        ) ?? [:]

        if let storedYears = try container.decodeIfPresent(
            Set<Int>.self,
            forKey: .seasonYears
        ) {
            seasonYears = storedYears
        } else {

            // Reconstruct as much as possible from an older snapshot.

            var discoveredYears = Set<Int>()

            for record in records.values {
                discoveredYears.insert(record.year)
            }

            for winner in eventWinners.values {
                discoveredYears.insert(winner.year)
            }

            for champion in champions.values {
                discoveredYears.insert(champion.year)
            }

            seasonYears = discoveredYears
        }
    }
}
