//
//  BeerGameRecordsModels.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct BeerGameRecordHoldersData {

    let eventRecords: [BeerGameEventRecord]

    let championships: [BeerGameChampionship]

    let accumulatedPoints: [AccumulatedBeerGamePoints]
}

struct AccumulatedBeerGamePoints: Identifiable {

    var id: String { player }

    let player: String

    let yearlyPoints: [Int: Double]

    let totalPoints: Double

    var seasonsPlayed: Int {
        yearlyPoints.values.filter {
            $0 > 0
        }.count
    }

    var averagePoints: Double {

        guard seasonsPlayed > 0 else {
            return 0
        }

        return totalPoints / Double(seasonsPlayed)
    }
}


struct BeerGameEventRecord: Identifiable {

    var id: String {
        "\(event)-\(player)"
    }

    let event: String
    let score: String
    let season: Int
    let player: String
}


struct BeerGameChampionship: Identifiable {

    var id: String { player }

    let player: String
    let championships: Int
}
