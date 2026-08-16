//
//  AccumulatedEarningsParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct AccumulatedEarningsParser {

    static func parse(
        rows: [[String]]
    ) -> [AccumulatedEarningsPlayer] {

        guard let titleRowIndex =
                rows.firstIndex(where: { row in

                    row.contains {
                        normalized($0) ==
                        "accumulated earnings"
                    }
                })
        else {
            return []
        }

        let headerRowIndex =
            titleRowIndex + 1

        guard headerRowIndex < rows.count else {
            return []
        }

        let headers =
            rows[headerRowIndex]

        guard
            let playerColumn =
                index(
                    of: "Player",
                    in: headers
                ),

            let winningsColumn =
                index(
                    of: "Winnings",
                    in: headers
                ),

            let feesColumn =
                index(
                    of: "Fees",
                    in: headers
                )

        else {
            return []
        }


        // MARK: Find year columns

        var yearColumns:
            [(year: Int, column: Int)] = []

        for (
            columnIndex,
            header
        ) in headers.enumerated() {

            let cleanedHeader =
                clean(header)

            if let year =
                    Int(cleanedHeader),
               year >= 2000,
               year <= 2100 {

                yearColumns.append(
                    (
                        year: year,
                        column: columnIndex
                    )
                )
            }
        }

        yearColumns.sort {
            $0.year < $1.year
        }


        // MARK: Parse Players

        var results:
            [AccumulatedEarningsPlayer] = []

        for row in rows.dropFirst(
            headerRowIndex + 1
        ) {

            let player =
                value(
                    row,
                    playerColumn
                )

            if player.isEmpty {
                break
            }


            // Every year gets an entry,
            // even when the spreadsheet says "-"

            var yearlyWinnings:
                [YearlyEarnings] = []

            for yearColumn in yearColumns {

                let rawValue =
                    value(
                        row,
                        yearColumn.column
                    )

                let amount =
                    moneyValue(rawValue)

                yearlyWinnings.append(
                    YearlyEarnings(
                        year: yearColumn.year,
                        amount: amount
                    )
                )
            }


            let totalWinnings =
                moneyValue(
                    value(
                        row,
                        winningsColumn
                    )
                ) ?? 0


            let totalFees =
                moneyValue(
                    value(
                        row,
                        feesColumn
                    )
                ) ?? 0


            results.append(
                AccumulatedEarningsPlayer(
                    player: player,
                    yearlyWinnings:
                        yearlyWinnings,
                    totalWinnings:
                        totalWinnings,
                    totalFees:
                        totalFees
                )
            )
        }

        return results
    }
}


// MARK: - Helpers

private extension AccumulatedEarningsParser {

    static func index(
        of header: String,
        in row: [String]
    ) -> Int? {

        row.firstIndex {
            normalized($0) ==
            normalized(header)
        }
    }


    static func normalized(
        _ value: String
    ) -> String {

        value
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }


    static func clean(
        _ value: String
    ) -> String {

        value
            .trimmingCharacters(
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


    static func moneyValue(
        _ text: String
    ) -> Double? {

        var cleaned =
            text
                .replacingOccurrences(
                    of: "$",
                    with: ""
                )
                .replacingOccurrences(
                    of: ",",
                    with: ""
                )
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )


        // Blank or "-" means no earnings
        guard !cleaned.isEmpty,
              cleaned != "-"
        else {
            return nil
        }


        // Handle accounting-style negatives:
        //
        // ($500)
        // becomes
        // -500

        if cleaned.hasPrefix("(") &&
            cleaned.hasSuffix(")") {

            cleaned =
                cleaned
                    .replacingOccurrences(
                        of: "(",
                        with: ""
                    )
                    .replacingOccurrences(
                        of: ")",
                        with: ""
                    )

            if let number =
                Double(cleaned) {

                return -number
            }
        }

        return Double(cleaned)
    }
}
