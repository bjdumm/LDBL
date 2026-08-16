//
//  FantasyWinLossModels.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import Foundation

struct FantasyWinLossData {

    let seasons: [FantasyActualSeason]
}


struct FantasyActualSeason: Identifiable {

    var id: Int { year }

    let year: Int
    let players: [FantasyActualRecord]
}


struct FantasyActualRecord: Identifiable {

    var id: String {
        "\(year)-\(player)"
    }

    let year: Int
    let player: String

    let wins: Int
    let losses: Int

    let points: Double

    var winPercentage: Double {

        let games = wins + losses

        guard games > 0 else {
            return 0
        }

        return Double(wins)
            / Double(games)
    }
}
