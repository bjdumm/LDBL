import Foundation

struct PlayerStatsSheetData {

    let players: [PlayerStats]
    let wins: [PlayerGameWins]

    let personalBests: [PlayerGameScores]
    let personalWorsts: [PlayerGameScores]
}


struct PlayerStats: Identifiable {

    var id: String { name }

    let name: String

    let weeklyHighPoints: Double
    let weeklyLowPoints: Double

    let beerGameFirstPlaces: Int
    let beerGameLastPlaces: Int

    let beerDieWins: Int
    let speedballWins: Int
}


struct PlayerGameWins: Identifiable {

    var id: String { name }

    let name: String

    let pong: Int
    let cornhole: Int
    let relays: Int
    let quarterPong: Int
    let flipCup: Int
    let darts: Int
    let dizzyBat: Int
    let fourCorners: Int
    let showcase: Int
}


struct PlayerGameScores: Identifiable {

    var id: String { name }

    let name: String

    let pong: Double?
    let relays: Double?
    let quarterPong: Double?
    let flipCup: Double?
    let dizzyBat: Double?
    let fourCorners: Double?
    let showcase: Double?
}

