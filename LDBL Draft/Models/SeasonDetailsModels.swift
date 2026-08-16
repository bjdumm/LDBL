//
//  SeasonDetailsModels.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct FantasySeasonDetails: Identifiable {
    var id: Int { year }

    let year: Int
    let players: [FantasySeasonPlayer]
}

struct FantasySeasonPlayer: Identifiable {
    var id: String {
        "\(year)-\(name)"
    }

    let year: Int
    let name: String
    let wins: Int
    let losses: Int
    let weeks: [FantasyWeekResult]

    var winPercentage: Double {
        let total = wins + losses

        guard total > 0 else {
            return 0
        }

        return Double(wins) / Double(total)
    }
}

struct FantasyWeekResult: Identifiable {
    var id: Int { week }

    let week: Int
    let wins: Int
    let losses: Int
}
