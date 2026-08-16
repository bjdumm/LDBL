//
//  SeasonDetailsParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct SeasonDetailsParser {

    static func parse(
        rows: [[String]]
    ) -> [FantasySeasonDetails] {

        var seasons: [FantasySeasonDetails] = []

        let seasonRows =
            rows.indices.filter { index in
                isSeasonRow(rows[index])
            }

        for (
            position,
            startIndex
        ) in seasonRows.enumerated() {

            guard let year =
                    Int(
                        value(
                            rows[startIndex],
                            3
                        )
                    )
            else {
                continue
            }

            let endIndex: Int

            if position + 1 < seasonRows.count {
                endIndex =
                    seasonRows[position + 1]
            } else {
                endIndex = rows.count
            }

            let season =
                parseSeason(
                    year: year,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    rows: rows
                )

            seasons.append(season)
        }

        return seasons.sorted {
            $0.year > $1.year
        }
    }
}

private extension SeasonDetailsParser {

    static func parseSeason(
        year: Int,
        startIndex: Int,
        endIndex: Int,
        rows: [[String]]
    ) -> FantasySeasonDetails {

        let playerStartRow =
            startIndex + 2

        var players:
            [FantasySeasonPlayer] = []

        guard playerStartRow < endIndex else {

            return FantasySeasonDetails(
                year: year,
                players: []
            )
        }

        for index in playerStartRow..<endIndex {

            let row = rows[index]

            let name =
                value(
                    row,
                    4
                )

            guard !name.isEmpty else {
                continue
            }

            var weeks:
                [FantasyWeekResult] = []

            // Week 1 begins in column F,
            // represented by indexes 5 and 6.
            for week in 1...13 {

                let winColumn =
                    5 + ((week - 1) * 2)

                let lossColumn =
                    winColumn + 1

                guard winColumn < row.count else {
                    break
                }

                let wins =
                    integer(
                        value(
                            row,
                            winColumn
                        )
                    )

                let losses =
                    integer(
                        value(
                            row,
                            lossColumn
                        )
                    )

                weeks.append(
                    FantasyWeekResult(
                        week: week,
                        wins: wins,
                        losses: losses
                    )
                )
            }

            let totalWins =
                weeks.reduce(0) {
                    $0 + $1.wins
                }

            let totalLosses =
                weeks.reduce(0) {
                    $0 + $1.losses
                }

            players.append(
                FantasySeasonPlayer(
                    year: year,
                    name: name,
                    wins: totalWins,
                    losses: totalLosses,
                    weeks: weeks
                )
            )
        }

        return FantasySeasonDetails(
            year: year,
            players: players
        )
    }


    static func isSeasonRow(
        _ row: [String]
    ) -> Bool {

        guard let year =
                Int(
                    value(
                        row,
                        3
                    )
                )
        else {
            return false
        }

        return year >= 2000 &&
               year <= 2100
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


    static func integer(
        _ value: String
    ) -> Int {

        if let intValue =
            Int(value) {

            return intValue
        }

        if let doubleValue =
            Double(value) {

            return Int(doubleValue)
        }

        return 0
    }
}
