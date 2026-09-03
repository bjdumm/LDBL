//
//  SpreadSheetService.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation


// MARK: - Single Sheet Response

struct SheetResponse: Decodable {

    let success: Bool

    let sheet: String?

    let rowCount: Int?

    let rows: [[String]]?

    let error: String?
}


// MARK: - All Sheets Response

struct AllSheetsResponse: Decodable {

    let success: Bool

    let sheets:
        [String: [[String]]]?

    let error: String?
}


// MARK: - Parsed League Payload

struct LeagueDataPayload {

    let seasonDetails:
        [FantasySeasonDetails]

    let fantasyWinLoss:
        FantasyWinLossData

    let accumulatedEarnings:
        [AccumulatedEarningsPlayer]

    let yearEndRosters:
        [YearEndRosterSeason]

    let scoreboard:
        [ScoreboardSeason]

    let beerGameRecordHolders:
        BeerGameRecordHoldersData

    let gamesAndRules:
        GamesRulesData
}


// MARK: - Fresh Fetch Result

struct LeagueDataFetchResult {

    let payload:
        LeagueDataPayload

    let rawSheets:
        [String: [[String]]]
}


// MARK: - Spreadsheet Service

final class SpreadsheetService {

    static let shared =
        SpreadsheetService()


    private init() {}


    private let baseURL =
        "https://script.google.com/macros/s/AKfycbzaxWLO3B0XJfxp90C05r62vTl1Bi9yLyIg-vQLVFqdsmwUDLOsEUc1u045cnXchzm4/exec"


    // MARK: - Fetch Entire League

    func fetchLeagueData()
        async throws
        -> LeagueDataFetchResult {

        var sheets =
            try await fetchAllSheets()

        let rosterSheets =
            await fetchAvailableYearEndRosterSheets()

        for (name, rows) in rosterSheets {
            sheets[name] = rows
        }

        let payload =
            try parseLeagueData(
                from: sheets
            )


        return LeagueDataFetchResult(
            payload: payload,
            rawSheets: sheets
        )
    }


    // MARK: - Parse Existing Raw Sheets

    func parseLeagueData(
        from sheets:
            [String: [[String]]]
    ) throws -> LeagueDataPayload {


        guard let seasonRows =
                sheets[
                    "Season Details"
                ]
        else {

            throw SpreadsheetError
                .missingSheet(
                    "Season Details"
                )
        }


        guard let winLossRows =
                sheets[
                    "LDBL Win-Loss"
                ]
        else {

            throw SpreadsheetError
                .missingSheet(
                    "LDBL Win-Loss"
                )
        }


        guard let recordHolderRows =
                sheets[
                    "LDBL Record Holders"
                ]
        else {

            throw SpreadsheetError
                .missingSheet(
                    "LDBL Record Holders"
                )
        }


        guard let scoreboardRows =
                sheets[
                    "Scoreboard ALL"
                ]
        else {

            throw SpreadsheetError
                .missingSheet(
                    "Scoreboard ALL"
                )
        }


        guard let rulesRows =
                sheets[
                    "Games & Rules 2026"
                ]
        else {

            throw SpreadsheetError
                .missingSheet(
                    "Games & Rules 2026"
                )
        }


        // MARK: Parse Locally

        let seasonDetails =
            SeasonDetailsParser
                .parse(
                    rows:
                        seasonRows
                )


        let fantasyWinLoss =
            FantasyWinLossParser
                .parse(
                    rows:
                        winLossRows
                )


        /*
         Both parsers use the SAME copy
         of LDBL Record Holders.
        */

        let accumulatedEarnings =
            AccumulatedEarningsParser
                .parse(
                    rows:
                        recordHolderRows
                )


        let beerGameRecordHolders =
            BeerGameRecordHoldersParser
                .parse(
                    rows:
                        recordHolderRows
                )


        let scoreboard =
            ScoreboardAllParser
                .parse(
                    rows:
                        scoreboardRows
                )


        let gamesAndRules =
            GamesAndRulesParser
                .parse(
                    rows:
                        rulesRows
                )

        let yearEndRosters =
            sheets.compactMap { name, rows -> YearEndRosterSeason? in
                guard name.hasPrefix("Year-End Roster "),
                      let year = Int(name.replacingOccurrences(of: "Year-End Roster ", with: ""))
                else { return nil }
                return YearEndRosterParser.parse(rows: rows, fallbackYear: year)
            }
            .sorted { $0.year > $1.year }


        return LeagueDataPayload(

            seasonDetails:
                seasonDetails,

            fantasyWinLoss:
                fantasyWinLoss,

            accumulatedEarnings:
                accumulatedEarnings,

            yearEndRosters:
                yearEndRosters,

            scoreboard:
                scoreboard,

            beerGameRecordHolders:
                beerGameRecordHolders,

            gamesAndRules:
                gamesAndRules
        )
    }


    // MARK: - Fetch All Sheets

    func fetchAllSheets()
        async throws
        -> [String: [[String]]] {

        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "_fresh", value: String(Date().timeIntervalSince1970))
        ]

        guard let url = components.url else {

            throw URLError(
                .badURL
            )
        }


        let maxAttempts =
            3


        for attempt in
            1...maxAttempts {

            print(
                "Requesting ALL league sheets",
                "| Attempt:",
                attempt
            )


            do {

                let (
                    data,
                    response
                ) =
                    try await
                    URLSession.shared
                        .data(
                            for: freshRequest(url)
                        )


                guard let httpResponse =
                        response
                            as? HTTPURLResponse
                else {

                    throw URLError(
                        .badServerResponse
                    )
                }


                print(
                    "ALL sheets HTTP Status:",
                    httpResponse.statusCode,
                    "| Attempt:",
                    attempt
                )


                if 200...299 ~=
                    httpResponse.statusCode {

                    let result =
                        try JSONDecoder()
                            .decode(
                                AllSheetsResponse.self,
                                from: data
                            )


                    guard result.success
                    else {

                        throw SpreadsheetError
                            .apiError(
                                result.error ??
                                "Unknown spreadsheet error"
                            )
                    }


                    guard let sheets =
                            result.sheets
                    else {

                        throw SpreadsheetError
                            .apiError(
                                "No sheet data returned."
                            )
                    }


                    print(
                        "Successfully loaded",
                        sheets.count,
                        "league sheets."
                    )


                    return sheets
                }


                if attempt <
                    maxAttempts {

                    try await
                        Task.sleep(
                            for:
                                .milliseconds(
                                    500 * attempt
                                )
                        )

                    continue
                }


                throw URLError(
                    .badServerResponse
                )

            } catch {

                if attempt ==
                    maxAttempts {

                    throw error
                }


                print(
                    "League request failed:",
                    error.localizedDescription,
                    "| Retrying..."
                )


                try await
                    Task.sleep(
                        for:
                            .milliseconds(
                                500 * attempt
                            )
                    )
            }
        }


        throw URLError(
            .badServerResponse
        )
    }


    // MARK: - Dynamic Year-End Roster Discovery

    private func fetchAvailableYearEndRosterSheets() async -> [String: [[String]]] {
        let currentYear = Calendar.current.component(.year, from: Date())
        var found: [String: [[String]]] = [:]

        for year in 2025...max(2025, currentYear) {
            let name = "Year-End Roster \(year)"
            do {
                let rows = try await fetchSheet(named: name)
                if !rows.isEmpty { found[name] = rows }
            } catch {
                print("No year-end roster sheet for \(year).")
            }
        }
        return found
    }


    // MARK: - Individual Sheet Fetch

    func fetchSheet(
        named sheetName: String
    ) async throws -> [[String]] {

        guard var components =
                URLComponents(
                    string: baseURL
                )
        else {

            throw URLError(
                .badURL
            )
        }


        components.queryItems = [

            URLQueryItem(
                name: "sheet",
                value: sheetName
            ),
            URLQueryItem(
                name: "_fresh",
                value: String(Date().timeIntervalSince1970)
            )
        ]


        guard let url =
                components.url
        else {

            throw URLError(
                .badURL
            )
        }


        print(
            "Requesting individual sheet:",
            sheetName
        )


        let (
            data,
            response
        ) =
            try await
            URLSession.shared
                .data(
                    for: freshRequest(url)
                )


        guard let httpResponse =
                response
                    as? HTTPURLResponse
        else {

            throw URLError(
                .badServerResponse
            )
        }


        print(
            "HTTP Status:",
            httpResponse.statusCode,
            "| Sheet:",
            sheetName
        )


        guard
            200...299 ~=
                httpResponse
                    .statusCode
        else {

            throw URLError(
                .badServerResponse
            )
        }


        let result =
            try JSONDecoder()
                .decode(
                    SheetResponse.self,
                    from: data
                )


        guard result.success
        else {

            throw SpreadsheetError
                .apiError(
                    result.error ??
                    "Unknown spreadsheet error"
                )
        }


        return result.rows ?? []
    }


    private func freshRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30
        )
        request.setValue("no-cache, no-store, max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        return request
    }


    // MARK: - Player Stats

    func loadPlayerStats()
        async throws
        -> PlayerStatsSheetData {

        let rows =
            try await
                fetchSheet(
                    named:
                        "Player Stats"
                )


        return PlayerStatsParser
            .parse(
                rows: rows
            )
    }


    // MARK: - Compatibility Loaders

    func loadScoreboardAll()
        async throws
        -> [ScoreboardSeason] {

        let rows =
            try await
                fetchSheet(
                    named:
                        "Scoreboard ALL"
                )


        return ScoreboardAllParser
            .parse(
                rows: rows
            )
    }


    func loadGamesAndRules()
        async throws
        -> GamesRulesData {

        let rows =
            try await
                fetchSheet(
                    named:
                        "Games & Rules 2026"
                )


        return GamesAndRulesParser
            .parse(
                rows: rows
            )
    }


    func loadBeerGameRecordHolders()
        async throws
        -> BeerGameRecordHoldersData {

        let rows =
            try await
                fetchSheet(
                    named:
                        "LDBL Record Holders"
                )


        return BeerGameRecordHoldersParser
            .parse(
                rows: rows
            )
    }


    func loadSeasonDetails()
        async throws
        -> [FantasySeasonDetails] {

        let rows =
            try await
                fetchSheet(
                    named:
                        "Season Details"
                )


        return SeasonDetailsParser
            .parse(
                rows: rows
            )
    }


    func loadAccumulatedEarnings()
        async throws
        -> [AccumulatedEarningsPlayer] {

        let rows =
            try await
                fetchSheet(
                    named:
                        "LDBL Record Holders"
                )


        return AccumulatedEarningsParser
            .parse(
                rows: rows
            )
    }


    func loadFantasyWinLoss()
        async throws
        -> FantasyWinLossData {

        let rows =
            try await
                fetchSheet(
                    named:
                        "LDBL Win-Loss"
                )


        return FantasyWinLossParser
            .parse(
                rows: rows
            )
    }
}


// MARK: - Errors

enum SpreadsheetError:
    LocalizedError {

    case apiError(String)

    case missingSheet(String)


    var errorDescription:
        String? {

        switch self {

        case .apiError(
            let message
        ):

            return message


        case .missingSheet(
            let sheet
        ):

            return
                "Missing spreadsheet tab: \(sheet)"
        }
    }
}
