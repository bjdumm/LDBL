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


        // MARK: - Year Columns

        var yearColumns:
            [(year: Int, column: Int)] = []


        for (
            columnIndex,
            header
        ) in headers.enumerated() {

            if let year =
                    Int(clean(header)),
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


        // MARK: - Players

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


            var yearlyWinnings:
                [YearlyEarnings] = []


            for yearColumn in yearColumns {

                let raw =
                    value(
                        row,
                        yearColumn.column
                    )


                yearlyWinnings.append(
                    YearlyEarnings(
                        year:
                            yearColumn.year,

                        amount:
                            SpreadsheetNumberParser
                                .number(raw)
                    )
                )
            }


            let totalWinnings =
                SpreadsheetNumberParser
                    .number(
                        value(
                            row,
                            winningsColumn
                        )
                    ) ?? 0


            let totalFees =
                SpreadsheetNumberParser
                    .number(
                        value(
                            row,
                            feesColumn
                        )
                    ) ?? 0


            results.append(
                AccumulatedEarningsPlayer(
                    player:
                        ManagerNameNormalizer
                            .normalize(player),

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
              index < row.count
        else {
            return ""
        }

        return clean(
            row[index]
        )
    }
}
