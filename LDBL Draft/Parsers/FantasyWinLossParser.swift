//
//  FantasyWinLossParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import Foundation

struct FantasyWinLossParser {

    static func parse(
        rows: [[String]]
    ) -> FantasyWinLossData {

        var seasonResults:
            [Int: [FantasyActualRecord]] = [:]

        for rowIndex in rows.indices {

            let row = rows[rowIndex]

            let yearColumns =
                findYearColumns(in: row)

            guard !yearColumns.isEmpty else {
                continue
            }

            let headerIndex =
                rowIndex + 1

            guard headerIndex < rows.count else {
                continue
            }

            let firstPlayerIndex =
                rowIndex + 2

            for yearInfo in yearColumns {

                parseSeason(
                    year: yearInfo.year,
                    startColumn: yearInfo.column,
                    firstPlayerIndex:
                        firstPlayerIndex,
                    rows: rows,
                    results: &seasonResults
                )
            }
        }

        let seasons =
            seasonResults.map {
                FantasyActualSeason(
                    year: $0.key,
                    players: $0.value
                )
            }
            .sorted {
                $0.year > $1.year
            }

        return FantasyWinLossData(
            seasons: seasons
        )
    }
}

private extension FantasyWinLossParser {

    static func findYearColumns(
        in row: [String]
    ) -> [(year: Int, column: Int)] {

        var results:
            [(year: Int, column: Int)] = []

        for (
            index,
            cell
        ) in row.enumerated() {

            let text =
                clean(cell)

            if let year =
                    Int(text),
               year >= 2000,
               year <= 2100 {

                results.append(
                    (
                        year: year,
                        column: index
                    )
                )
            }
        }

        return results
    }


    static func parseSeason(
        year: Int,
        startColumn: Int,
        firstPlayerIndex: Int,
        rows: [[String]],
        results:
            inout [Int: [FantasyActualRecord]]
    ) {

        var records:
            [FantasyActualRecord] = []

        var rowIndex =
            firstPlayerIndex

        while rowIndex < rows.count {

            let row =
                rows[rowIndex]

            // Player name is one column
            // before the first W column.
            let nameColumn =
                startColumn - 1

            let rawName =
                value(
                    row,
                    nameColumn
                )

            guard !rawName.isEmpty else {
                break
            }

            let wins =
                integer(
                    value(
                        row,
                        startColumn
                    )
                )

            let losses =
                integer(
                    value(
                        row,
                        startColumn + 1
                    )
                )

            let points =
                double(
                    value(
                        row,
                        startColumn + 2
                    )
                )

            records.append(
                FantasyActualRecord(
                    year: year,

                    player:
                        ManagerNameNormalizer
                            .normalize(
                                rawName
                            ),

                    wins: wins,
                    losses: losses,
                    points: points
                )
            )

            rowIndex += 1
        }

        // Don't add future empty seasons.
        if records.contains(
            where: {
                $0.wins > 0 ||
                $0.losses > 0 ||
                $0.points > 0
            }
        ) {

            results[year] = records
        }
    }


    static func clean(
        _ value: String
    ) -> String {

        value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }


    static func value(
        _ row: [String],
        _ index: Int
    ) -> String {

        guard index >= 0,
              index < row.count else {
            return ""
        }

        return clean(row[index])
    }


    static func integer(
        _ text: String
    ) -> Int {

        if let value = Int(text) {
            return value
        }

        if let value = Double(text) {
            return Int(value)
        }

        return 0
    }


    static func double(
        _ text: String
    ) -> Double {

        let cleaned =
            text.replacingOccurrences(
                of: ",",
                with: ""
            )

        return Double(cleaned) ?? 0
    }
}
