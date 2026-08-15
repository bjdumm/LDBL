//
//  GamesAndRulesParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct GamesAndRulesParser {

    static func parse(
        rows: [[String]]
    ) -> GamesRulesData {

        var eventDate = ""

        var generalRules: [String] = []

        var games: [BeerGameRule] = []

        var showcaseNotes: [String] = []

        var foundGameTable = false
        var finishedGames = false

        for row in rows {

            let first = value(row, 0)
            let second = value(row, 1)
            let fourth = value(row, 3)

            // Labor Day Weekend 2025, etc.
            if eventDate.isEmpty &&
                second.lowercased()
                    .contains("weekend") {

                eventDate = second
            }

            // Overall rules
            if first.uppercased() == "RULE:" {

                if !second.isEmpty {
                    generalRules.append(second)
                }

                continue
            }

            // Locate game table
            if first == "Game" &&
                second == "Description" {

                foundGameTable = true
                continue
            }

            guard foundGameTable else {
                continue
            }

            // #1, #2, etc.
            if first.hasPrefix("#") {

                let title =
                    extractGameTitle(
                        from: second
                    )

                games.append(
                    BeerGameRule(
                        number: first,
                        title: title,
                        description: second,
                        drinkingRequirement: fourth
                    )
                )

                continue
            }

            // Once #10 has been parsed, subsequent column-B
            // text belongs to the showcase explanation.
            if games.last?.number == "#10" {

                finishedGames = true
            }

            if finishedGames &&
                !second.isEmpty {

                showcaseNotes.append(second)
            }
        }

        return GamesRulesData(
            eventDate: eventDate,
            generalRules: generalRules,
            games: games,
            showcaseNotes: showcaseNotes
        )
    }
}

private extension GamesAndRulesParser {

    static func extractGameTitle(
        from description: String
    ) -> String {

        if let separator =
            description.range(of: " - ") {

            return String(
                description[
                    ..<separator.lowerBound
                ]
            )
        }

        return description
    }


    static func value(
        _ row: [String],
        _ index: Int
    ) -> String {

        guard index >= 0,
              index < row.count else {
            return ""
        }

        return row[index]
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }
}
