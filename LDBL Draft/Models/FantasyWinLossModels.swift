import Foundation

struct FantasyWinLossData {

    let seasons: [FantasyActualSeason]

    let careerRecords: [FantasyCareerRecord]

    let yearlyFinishes: [FantasyYearlyFinish]

    let careerTitles: [FantasyCareerTitles]
}


// MARK: - Season Data

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


// MARK: - Career Record

struct FantasyCareerRecord: Identifiable {

    var id: String { player }

    let player: String

    let wins: Int

    let losses: Int

    let winPercentage: Double

    let pointsPerGame: Double
}


// MARK: - Yearly Finish

struct FantasyYearlyFinish: Identifiable {

    var id: Int { year }

    let year: Int

    let firstPlace: String

    let secondPlace: String

    let thirdPlace: String

    let regularSeasonChampion: String
}




struct FantasyCareerTitles: Identifiable {

    var id: String { player }

    let player: String

    let championships: Int

    let regularSeasonChampionships: Int

    let seasonHighPointsTitles: Int
}
