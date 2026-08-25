import Foundation

struct FantasyWinLossParser {

    static func parse(
        rows: [[String]]
    ) -> FantasyWinLossData {

        var resultsByYear:
            [Int: [FantasyActualRecord]] = [:]

        for rowIndex in rows.indices {

            guard rowIndex + 1 < rows.count else {
                continue
            }

            let yearRow = rows[rowIndex]
            let headerRow = rows[rowIndex + 1]

            let yearColumns =
                findYearColumns(
                    in: yearRow,
                    headerRow: headerRow
                )

            guard !yearColumns.isEmpty else {
                continue
            }

            let firstPlayerRow =
                rowIndex + 2

            for yearInfo in yearColumns {

                let records =
                    parseSeason(
                        year: yearInfo.year,
                        statsColumn: yearInfo.column,
                        firstPlayerRow: firstPlayerRow,
                        rows: rows
                    )

                // Ignore empty future placeholders
                guard !records.isEmpty else {
                    continue
                }

                resultsByYear[
                    yearInfo.year
                ] = records
            }
        }


        let seasons =
            resultsByYear
                .map { year, players in

                    FantasyActualSeason(
                        year: year,
                        players: players
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


// MARK: - Private Helpers

private extension FantasyWinLossParser {

    /*
     In this spreadsheet the player names
     always live in column B.

     Swift array index:
     A = 0
     B = 1
    */

    static let playerColumn = 1


    static func findYearColumns(
        in yearRow: [String],
        headerRow: [String]
    ) -> [(year: Int, column: Int)] {

        var results:
            [(year: Int, column: Int)] = []

        for (
            column,
            cell
        ) in yearRow.enumerated() {

            guard
                let year =
                    Int(clean(cell)),

                year >= 2000,
                year <= 2100

            else {
                continue
            }


            // A real fantasy season table must have:
            //
            // W | L | Pts
            //
            // immediately underneath the year.

            guard
                value(
                    headerRow,
                    column
                )
                .uppercased() == "W",

                value(
                    headerRow,
                    column + 1
                )
                .uppercased() == "L",

                isPointsHeader(
                    value(
                        headerRow,
                        column + 2
                    )
                )

            else {
                continue
            }


            results.append(
                (
                    year: year,
                    column: column
                )
            )
        }

        return results
    }


    static func parseSeason(
        year: Int,
        statsColumn: Int,
        firstPlayerRow: Int,
        rows: [[String]]
    ) -> [FantasyActualRecord] {

        var records:
            [FantasyActualRecord] = []

        var rowIndex =
            firstPlayerRow


        while rowIndex < rows.count {

            let row =
                rows[rowIndex]


            // IMPORTANT:
            //
            // Player names always come from
            // column B, regardless of whether
            // we're reading 2016, 2017, 2018,
            // 2019, etc.

            let rawPlayer =
                value(
                    row,
                    playerColumn
                )


            // Once column B becomes blank,
            // this season block is finished.

            if rawPlayer.isEmpty {
                break
            }


            let wins =
                integer(
                    value(
                        row,
                        statsColumn
                    )
                )


            let losses =
                integer(
                    value(
                        row,
                        statsColumn + 1
                    )
                )


            let points =
                double(
                    value(
                        row,
                        statsColumn + 2
                    )
                )


            /*
             2026 and 2027 already exist as
             blank templates in the workbook.

             Don't create records from them.
            */

            let hasData =
                wins > 0 ||
                losses > 0 ||
                points > 0


            if hasData {

                records.append(
                    FantasyActualRecord(
                        year: year,

                        player:
                            ManagerNameNormalizer
                                .normalize(
                                    rawPlayer
                                ),

                        wins: wins,

                        losses: losses,

                        points: points
                    )
                )
            }


            rowIndex += 1
        }


        return records
    }


    static func isPointsHeader(
        _ text: String
    ) -> Bool {

        let header =
            clean(text)
                .lowercased()

        return
            header == "pts" ||
            header == "points"
    }


    static func clean(
        _ text: String
    ) -> String {

        text
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
    }


    static func value(
        _ row: [String],
        _ column: Int
    ) -> String {

        guard
            column >= 0,
            column < row.count

        else {
            return ""
        }

        return clean(
            row[column]
        )
    }


    static func integer(
        _ text: String
    ) -> Int {

        let cleaned =
            text
                .replacingOccurrences(
                    of: ",",
                    with: ""
                )

        if let value =
            Int(cleaned) {

            return value
        }

        if let value =
            Double(cleaned) {

            return Int(value)
        }

        return 0
    }


    static func double(
        _ text: String
    ) -> Double {

        let cleaned =
            text
                .replacingOccurrences(
                    of: ",",
                    with: ""
                )
                .replacingOccurrences(
                    of: "$",
                    with: ""
                )

        return Double(cleaned) ?? 0
    }
}
