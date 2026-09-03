//
//  ScoreboardModels.swift
//  LDBL Draft
//

import Foundation

struct ScoreboardSeason: Identifiable {
    var id: Int { year }

    let year: Int
    let entries: [ScoreboardEntry]
    let participants: [String]

    init(
        year: Int,
        entries: [ScoreboardEntry],
        participants: [String]? = nil
    ) {
        self.year = year
        self.entries = entries

        if let participants {
            self.participants = participants
        } else {
            self.participants = entries.map {
                ManagerNameNormalizer.normalize($0.player)
            }
        }
    }
}

struct ScoreboardEntry: Identifiable {
    var id: String {
        "\(year)-\(player)"
    }

    let year: Int
    let place: Int
    let player: String
    let events: [ScoreboardEventResult]
    let totalPoints: Int
}

struct ScoreboardEventResult: Identifiable {
    var id: String { event }

    let event: String
    let result: String
    let points: Int
    let pointsEntered: Bool

    init(
        event: String,
        result: String,
        points: Int,
        pointsEntered: Bool = true
    ) {
        self.event = event
        self.result = result
        self.points = points
        self.pointsEntered = pointsEntered
    }
}
