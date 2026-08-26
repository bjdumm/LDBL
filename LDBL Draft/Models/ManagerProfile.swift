//
//  ManagerProfile.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import Foundation


struct ManagerProfile: Identifiable {

    var id: String { name }

    let name: String

    let seasons:
        [ManagerSeasonStats]

    let earnings:
        AccumulatedEarningsPlayer?

    let beerGameResults:
        [ScoreboardEntry]

    let actualFantasyRecords:
        [FantasyActualRecord]

    let fantasyFinishes:
        [ManagerFantasyFinish]


    // MARK: - All-Play Fantasy

    var allPlayCareerWins: Int {

        seasons.reduce(0) {
            $0 + $1.wins
        }
    }


    var allPlayCareerLosses: Int {

        seasons.reduce(0) {
            $0 + $1.losses
        }
    }


    var allPlayCareerWinPercentage:
        Double {

        let games =
            allPlayCareerWins +
            allPlayCareerLosses

        guard games > 0 else {
            return 0
        }

        return Double(
            allPlayCareerWins
        ) / Double(games)
    }


    var seasonsPlayed: Int {
        seasons.count
    }


    // MARK: - Actual Fantasy

    var actualCareerWins: Int {

        actualFantasyRecords.reduce(0) {
            $0 + $1.wins
        }
    }


    var actualCareerLosses: Int {

        actualFantasyRecords.reduce(0) {
            $0 + $1.losses
        }
    }


    var actualCareerWinPercentage:
        Double {

        let games =
            actualCareerWins +
            actualCareerLosses

        guard games > 0 else {
            return 0
        }

        return Double(
            actualCareerWins
        ) / Double(games)
    }


    // MARK: - Fantasy Finishes

    var fantasyChampionships: Int {

        fantasyFinishes.filter {
            $0.place == 1
        }.count
    }


    func fantasyFinish(
        for year: Int
    ) -> ManagerFantasyFinish? {

        fantasyFinishes.first {
            $0.year == year
        }
    }


    // MARK: - Earnings

    var totalWinnings: Double {
        earnings?.totalWinnings ?? 0
    }


    var totalFees: Double {
        earnings?.totalFees ?? 0
    }


    var returnAmount: Double {
        earnings?.returnAmount ?? 0
    }


    // MARK: - Beer Games

    var beerGameSeasonsPlayed: Int {
        beerGameResults.count
    }


    var beerGameTotalPoints: Int {

        beerGameResults.reduce(0) {
            $0 + $1.totalPoints
        }
    }


    var averageBeerGamePoints:
        Double {

        guard !beerGameResults.isEmpty else {
            return 0
        }

        return Double(
            beerGameTotalPoints
        ) / Double(
            beerGameResults.count
        )
    }


    var bestBeerGameFinish: Int? {

        beerGameResults
            .map(\.place)
            .min()
    }


    var beerGameChampionships: Int {

        beerGameResults.filter {
            $0.place == 1
        }.count
    }
}


// MARK: - Manager Season Stats

struct ManagerSeasonStats:
    Identifiable {

    var id: String {
        "\(manager)-\(year)"
    }

    let manager: String

    let year: Int

    let wins: Int

    let losses: Int


    var winPercentage: Double {

        let games =
            wins + losses

        guard games > 0 else {
            return 0
        }

        return Double(wins)
            / Double(games)
    }
}


// MARK: - Manager Fantasy Finish

struct ManagerFantasyFinish:
    Identifiable {

    var id: String {
        "\(year)-\(place)"
    }

    let year: Int

    let place: Int
}
