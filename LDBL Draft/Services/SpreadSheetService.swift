//
//  SpreadSheetService.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct SheetResponse: Decodable {
    let success: Bool
    let sheet: String?
    let rowCount: Int?
    let rows: [[String]]?
    let error: String?
}

final class SpreadsheetService {

    static let shared = SpreadsheetService()

    private init() {}

    private let baseURL =
        "https://script.google.com/macros/s/AKfycbzaxWLO3B0XJfxp90C05r62vTl1Bi9yLyIg-vQLVFqdsmwUDLOsEUc1u045cnXchzm4/exec"

    func fetchSheet(named sheetName: String) async throws -> [[String]] {

        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(
                name: "sheet",
                value: sheetName
            )
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("Requesting:", url.absoluteString)

        let (data, response) =
            try await URLSession.shared.data(from: url)

        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("HTTP Status:", httpResponse.statusCode)

        guard 200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let result =
            try JSONDecoder().decode(
                SheetResponse.self,
                from: data
            )

        guard result.success else {
            throw SpreadsheetError.apiError(
                result.error ?? "Unknown spreadsheet error"
            )
        }

        return result.rows ?? []
    }
    
    func loadPlayerStats() async throws -> PlayerStatsSheetData {

        let rows =
            try await fetchSheet(
                named: "Player Stats"
            )

        return PlayerStatsParser.parse(
            rows: rows
        )
    }
    
    // MARK: - Beer Games

    func loadScoreboardAll()
        async throws -> [ScoreboardSeason] {

        let rows =
            try await fetchSheet(
                named: "Scoreboard ALL"
            )

        return ScoreboardAllParser.parse(
            rows: rows
        )
    }


    func loadGamesAndRules()
        async throws -> GamesRulesData {

        let rows =
            try await fetchSheet(
                named: "Games & Rules 2026"
            )

        return GamesAndRulesParser.parse(
            rows: rows
        )
    }


    func loadBeerGameRecordHolders()
        async throws
        -> BeerGameRecordHoldersData {

        let rows =
            try await fetchSheet(
                named: "LDBL Record Holders"
            )

        return BeerGameRecordHoldersParser.parse(
            rows: rows
        )
    }
    
    // MARK: - Fantasy

    func loadSeasonDetails()
        async throws -> [FantasySeasonDetails] {

        let rows =
            try await fetchSheet(
                named: "Season Details"
            )

        return SeasonDetailsParser.parse(
            rows: rows
        )
    }
    
    func loadAccumulatedEarnings()
        async throws -> [AccumulatedEarningsPlayer] {

        let rows =
            try await fetchSheet(
                named: "LDBL Record Holders"
            )

        return AccumulatedEarningsParser.parse(
            rows: rows
        )
    }
    
    // MARK: - Managers

    func loadManagerProfiles()
        async throws -> [ManagerProfile] {

        async let seasonRequest =
            loadSeasonDetails()

        async let earningsRequest =
            loadAccumulatedEarnings()

        async let scoreboardRequest =
            loadScoreboardAll()

        async let actualRecordsRequest =
            loadFantasyWinLoss()


        let (
            seasons,
            earnings,
            scoreboard,
            actualRecords
        ) = try await (
            seasonRequest,
            earningsRequest,
            scoreboardRequest,
            actualRecordsRequest
        )


        var names = Set<String>()


        // MARK: - Fantasy Names

        for season in seasons {

            for player in season.players {

                names.insert(
                    ManagerNameNormalizer
                        .normalize(
                            player.name
                        )
                )
            }
        }


        // MARK: - Earnings Names

        for player in earnings {

            names.insert(
                ManagerNameNormalizer
                    .normalize(
                        player.player
                    )
            )
        }


        // MARK: - Beer Games Names

        for beerGameSeason in scoreboard {

            for entry in beerGameSeason.entries {

                names.insert(
                    ManagerNameNormalizer
                        .normalize(
                            entry.player
                        )
                )
            }
        }


        // MARK: - Actual Fantasy Names

        for season in actualRecords.seasons {

            for player in season.players {

                names.insert(
                    ManagerNameNormalizer
                        .normalize(
                            player.player
                        )
                )
            }
        }


        // MARK: - Remove Managers From List

        names.remove("Eagler")
        names.remove("Handy")
        names.remove("HANDY")
        names.remove("Jim")


        // MARK: - Build Profiles

        let profiles =
            names.map { name in


                // MARK: Fantasy Seasons

                var managerSeasons:
                    [ManagerSeasonStats] = []


                for season in seasons {

                    if let player =
                        season.players.first(
                            where: {

                                ManagerNameNormalizer
                                    .normalize(
                                        $0.name
                                    ) == name
                            }
                        ) {

                        managerSeasons.append(
                            ManagerSeasonStats(
                                manager:
                                    name,

                                year:
                                    season.year,

                                wins:
                                    player.wins,

                                losses:
                                    player.losses
                            )
                        )
                    }
                }


                // MARK: Actual Fantasy Records

                let managerActualRecords =
                    actualRecords.seasons
                        .flatMap {
                            $0.players
                        }
                        .filter {

                            ManagerNameNormalizer
                                .normalize(
                                    $0.player
                                ) == name
                        }
                        .sorted {
                            $0.year > $1.year
                        }


                // MARK: Fantasy Finishes

                var managerFantasyFinishes:
                    [ManagerFantasyFinish] = []


                for finish in
                    actualRecords.yearlyFinishes {

                    let firstPlace =
                        ManagerNameNormalizer
                            .normalize(
                                finish.firstPlace
                            )

                    let secondPlace =
                        ManagerNameNormalizer
                            .normalize(
                                finish.secondPlace
                            )

                    let thirdPlace =
                        ManagerNameNormalizer
                            .normalize(
                                finish.thirdPlace
                            )


                    if firstPlace == name {

                        managerFantasyFinishes.append(
                            ManagerFantasyFinish(
                                year:
                                    finish.year,
                                place:
                                    1
                            )
                        )

                    } else if secondPlace == name {

                        managerFantasyFinishes.append(
                            ManagerFantasyFinish(
                                year:
                                    finish.year,
                                place:
                                    2
                            )
                        )

                    } else if thirdPlace == name {

                        managerFantasyFinishes.append(
                            ManagerFantasyFinish(
                                year:
                                    finish.year,
                                place:
                                    3
                            )
                        )
                    }
                }


                // MARK: Earnings

                let managerEarnings =
                    earnings.first {

                        ManagerNameNormalizer
                            .normalize(
                                $0.player
                            ) == name
                    }


                // MARK: Beer Games

                let beerGameResults =
                    scoreboard
                        .flatMap {
                            $0.entries
                        }
                        .filter {

                            ManagerNameNormalizer
                                .normalize(
                                    $0.player
                                ) == name
                        }
                        .sorted {
                            $0.year > $1.year
                        }


                // MARK: Manager Profile

                return ManagerProfile(

                    name:
                        name,

                    seasons:
                        managerSeasons
                            .sorted {
                                $0.year > $1.year
                            },

                    earnings:
                        managerEarnings,

                    beerGameResults:
                        beerGameResults,

                    actualFantasyRecords:
                        managerActualRecords,

                    fantasyFinishes:
                        managerFantasyFinishes
                            .sorted {
                                $0.year > $1.year
                            }
                )
            }


        return profiles.sorted {
            $0.name < $1.name
        }
    }
    
    
    func loadFantasyWinLoss()
        async throws -> FantasyWinLossData {

        let rows =
            try await fetchSheet(
                named: "LDBL Win-Loss"
            )

        return FantasyWinLossParser.parse(
            rows: rows
        )
    }
}







enum SpreadsheetError: LocalizedError {

    case apiError(String)

    var errorDescription: String? {

        switch self {

        case .apiError(let message):
            return message
        }
    }
}
