//
//  PlayerStatsParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct PlayerStatsParser {

    static func parse(
        rows: [[String]]
    ) -> PlayerStatsSheetData {

        PlayerStatsSheetData(
            players:
                parseOverallStats(rows),

            wins:
                parseGameWins(rows),

            personalBests:
                parseScores(
                    rows,
                    sectionName: "Personal Bests"
                ),

            personalWorsts:
                parseScores(
                    rows,
                    sectionName: "Personal Worsts"
                )
        )
    }
}

private extension PlayerStatsParser {

    static func parseOverallStats(
        _ rows: [[String]]
    ) -> [PlayerStats] {

        let requiredHeaders = [
            "Player",
            "Weekly High Points",
            "Weekly Low Points"
        ]

        guard let table =
                SpreadsheetSectionFinder.table(
                    in: rows,
                    requiredHeaders: requiredHeaders,
                    stopAtBlankKeyColumn: "Player"
                )
        else {
            return []
        }

        return table.rows.compactMap { row in

            let name =
                table.string(
                    in: row,
                    header: "Player"
                )

            guard !name.isEmpty else {
                return nil
            }

            return PlayerStats(
                name: name,

                weeklyHighPoints:
                    table.double(
                        in: row,
                        header: "Weekly High Points"
                    ),

                weeklyLowPoints:
                    table.double(
                        in: row,
                        header: "Weekly Low Points"
                    ),

                beerGameFirstPlaces:
                    table.int(
                        in: row,
                        header: "1st Place in a Beer Game"
                    ),

                beerGameLastPlaces:
                    table.int(
                        in: row,
                        header: "Last Place in a Beer Game"
                    ),

                beerDieWins:
                    table.int(
                        in: row,
                        header: "Beer Die Wins"
                    ),

                speedballWins:
                    table.int(
                        in: row,
                        header: "Speedball Wins"
                    )
            )
        }
    }


    static func parseGameWins(
        _ rows: [[String]]
    ) -> [PlayerGameWins] {

        let requiredHeaders = [
            "Player",
            "Pong",
            "Cornhole",
            "Relays"
        ]

        guard let table =
                SpreadsheetSectionFinder.table(
                    in: rows,
                    requiredHeaders: requiredHeaders,
                    stopAtBlankKeyColumn: "Player"
                )
        else {
            return []
        }

        return table.rows.compactMap { row in

            let name =
                table.string(
                    in: row,
                    header: "Player"
                )

            guard !name.isEmpty else {
                return nil
            }

            return PlayerGameWins(
                name: name,

                pong:
                    table.int(
                        in: row,
                        header: "Pong"
                    ),

                cornhole:
                    table.int(
                        in: row,
                        header: "Cornhole"
                    ),

                relays:
                    table.int(
                        in: row,
                        header: "Relays"
                    ),

                quarterPong:
                    table.int(
                        in: row,
                        header: "Quarter Pong"
                    ),

                flipCup:
                    table.int(
                        in: row,
                        header: "Flip Cup"
                    ),

                darts:
                    table.int(
                        in: row,
                        header: "Darts"
                    ),

                dizzyBat:
                    table.int(
                        in: row,
                        header: "Dizzy Bat"
                    ),

                fourCorners:
                    table.int(
                        in: row,
                        header: "Four Corners"
                    ),

                showcase:
                    table.int(
                        in: row,
                        header: "Showcase"
                    )
            )
        }
    }


    static func parseScores(
        _ rows: [[String]],
        sectionName: String
    ) -> [PlayerGameScores] {

        let requiredHeaders = [
            "Player",
            "Pong",
            "Relays"
        ]

        guard let table =
                SpreadsheetSectionFinder.tableAfterSection(
                    in: rows,
                    sectionName: sectionName,
                    requiredHeaders: requiredHeaders,
                    stopAtBlankKeyColumn: "Player"
                )
        else {
            return []
        }

        return table.rows.compactMap { row in

            let name =
                table.string(
                    in: row,
                    header: "Player"
                )

            guard !name.isEmpty else {
                return nil
            }

            return PlayerGameScores(
                name: name,

                pong:
                    table.optionalDouble(
                        in: row,
                        header: "Pong"
                    ),

                relays:
                    table.optionalDouble(
                        in: row,
                        header: "Relays"
                    ),

                quarterPong:
                    table.optionalDouble(
                        in: row,
                        header: "Quarter Pong"
                    ),

                flipCup:
                    table.optionalDouble(
                        in: row,
                        header: "Flip Cup"
                    ),

                dizzyBat:
                    table.optionalDouble(
                        in: row,
                        header: "Dizzy Bat"
                    ),

                fourCorners:
                    table.optionalDouble(
                        in: row,
                        header: "Four Corners"
                    ),

                showcase:
                    table.optionalDouble(
                        in: row,
                        header: "Showcase"
                    )
            )
        }
    }
}
