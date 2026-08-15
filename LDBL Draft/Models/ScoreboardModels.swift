//
//  ScoreboardModels.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct ScoreboardSeason: Identifiable {
    var id: Int { year }

    let year: Int
    let entries: [ScoreboardEntry]
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
}
