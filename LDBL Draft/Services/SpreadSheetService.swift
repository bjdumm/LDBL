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
