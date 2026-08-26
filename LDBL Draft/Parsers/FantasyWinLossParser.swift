import Foundation

struct FantasyWinLossParser {

    static func parse(
        rows: [[String]]
    ) -> FantasyWinLossData {

        let seasons =
            parseSeasons(rows)

        let careerRecords =
            parseCareerRecords(rows)

        let yearlyFinishes =
            parseYearlyFinishes(rows)

        let careerTitles =
            parseCareerTitles(
                rows,
                yearlyFinishes: yearlyFinishes
            )

        return FantasyWinLossData(
            seasons: seasons,
            careerRecords: careerRecords,
            yearlyFinishes: yearlyFinishes,
            careerTitles: careerTitles
        )
    }
}


// MARK: - Seasons

private extension FantasyWinLossParser {

    static func parseSeasons(
        _ rows: [[String]]
    ) -> [FantasyActualSeason] {

        var resultsByYear:
            [Int: [FantasyActualRecord]] = [:]


        for rowIndex in rows.indices {

            guard rowIndex + 1 < rows.count else {
                continue
            }

            let yearRow =
                rows[rowIndex]

            let headerRow =
                rows[rowIndex + 1]


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
                        year:
                            yearInfo.year,

                        statsColumn:
                            yearInfo.column,

                        firstPlayerRow:
                            firstPlayerRow,

                        rows:
                            rows
                    )


                guard !records.isEmpty else {
                    continue
                }


                resultsByYear[
                    yearInfo.year
                ] = records
            }
        }


        return resultsByYear
            .map { year, players in

                FantasyActualSeason(
                    year: year,
                    players: players
                )
            }
            .sorted {
                $0.year > $1.year
            }
    }


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


            let rawPlayer =
                value(
                    row,
                    playerColumn
                )


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
}


// MARK: - Career Records

private extension FantasyWinLossParser {

    static func parseCareerRecords(
        _ rows: [[String]]
    ) -> [FantasyCareerRecord] {

        guard let headerRowIndex =
                rows.firstIndex(
                    where: { row in

                        row.contains {
                            clean($0) == "Win %"
                        }
                        &&
                        row.contains {
                            clean($0) == "PPG"
                        }
                    }
                )
        else {
            return []
        }


        let headers =
            rows[headerRowIndex]


        guard
            let winsColumn =
                index(
                    of: "W",
                    in: headers,
                    startingAt: 18
                ),

            let lossesColumn =
                index(
                    of: "L",
                    in: headers,
                    startingAt: winsColumn + 1
                ),

            let winPercentColumn =
                index(
                    of: "Win %",
                    in: headers
                ),

            let ppgColumn =
                index(
                    of: "PPG",
                    in: headers
                )

        else {
            return []
        }


        let playerColumn =
            winsColumn - 1


        var results:
            [FantasyCareerRecord] = []


        for row in rows.dropFirst(
            headerRowIndex + 1
        ) {

            let rawPlayer =
                value(
                    row,
                    playerColumn
                )


            if rawPlayer.isEmpty {
                break
            }


            results.append(
                FantasyCareerRecord(
                    player:
                        ManagerNameNormalizer
                            .normalize(
                                rawPlayer
                            ),

                    wins:
                        integer(
                            value(
                                row,
                                winsColumn
                            )
                        ),

                    losses:
                        integer(
                            value(
                                row,
                                lossesColumn
                            )
                        ),

                    winPercentage:
                        percentage(
                            value(
                                row,
                                winPercentColumn
                            )
                        ),

                    pointsPerGame:
                        double(
                            value(
                                row,
                                ppgColumn
                            )
                        )
                )
            )
        }


        return results.sorted {

            if $0.winPercentage ==
                $1.winPercentage {

                return $0.wins >
                    $1.wins
            }

            return $0.winPercentage >
                $1.winPercentage
        }
    }
}


// MARK: - Yearly Finishes

private extension FantasyWinLossParser {

    static func parseYearlyFinishes(
        _ rows: [[String]]
    ) -> [FantasyYearlyFinish] {

        guard let headerRowIndex =
                rows.firstIndex(
                    where: { row in

                        row.contains {
                            clean($0) == "Year"
                        }
                        &&
                        row.contains {
                            clean($0) == "1st"
                        }
                        &&
                        row.contains {
                            clean($0) == "2nd"
                        }
                        &&
                        row.contains {
                            clean($0) == "3rd"
                        }
                        &&
                        row.contains {
                            clean($0) == "Reg Champ"
                        }
                    }
                )
        else {
            return []
        }


        let headers =
            rows[headerRowIndex]


        guard
            let yearColumn =
                index(
                    of: "Year",
                    in: headers
                ),

            let firstColumn =
                index(
                    of: "1st",
                    in: headers
                ),

            let secondColumn =
                index(
                    of: "2nd",
                    in: headers
                ),

            let thirdColumn =
                index(
                    of: "3rd",
                    in: headers
                ),

            let championColumn =
                index(
                    of: "Reg Champ",
                    in: headers
                )

        else {
            return []
        }


        var results:
            [FantasyYearlyFinish] = []


        for row in rows.dropFirst(
            headerRowIndex + 1
        ) {

            guard let year =
                    Int(
                        value(
                            row,
                            yearColumn
                        )
                    )
            else {
                break
            }


            let first =
                ManagerNameNormalizer.normalize(
                    value(
                        row,
                        firstColumn
                    )
                )


            let second =
                ManagerNameNormalizer.normalize(
                    value(
                        row,
                        secondColumn
                    )
                )


            let third =
                ManagerNameNormalizer.normalize(
                    value(
                        row,
                        thirdColumn
                    )
                )


            let champion =
                ManagerNameNormalizer.normalize(
                    value(
                        row,
                        championColumn
                    )
                )


            results.append(
                FantasyYearlyFinish(
                    year: year,

                    firstPlace: first,

                    secondPlace: second,

                    thirdPlace: third,

                    regularSeasonChampion:
                        champion
                )
            )
        }


        return results.sorted {
            $0.year > $1.year
        }
    }
}


// MARK: - Career Titles

private extension FantasyWinLossParser {

    static func parseCareerTitles(
        _ rows: [[String]],
        yearlyFinishes: [FantasyYearlyFinish]
    ) -> [FantasyCareerTitles] {

        guard let headerRowIndex =
                rows.firstIndex(
                    where: { row in

                        row.contains {
                            clean($0) ==
                            "Reg Season Champ"
                        }
                        &&
                        row.contains {
                            clean($0) ==
                            "Season High Points"
                        }
                    }
                )
        else {
            return []
        }


        let headers =
            rows[headerRowIndex]


        guard
            let regChampColumn =
                index(
                    of:
                        "Reg Season Champ",
                    in:
                        headers
                ),

            let highPointsColumn =
                index(
                    of:
                        "Season High Points",
                    in:
                        headers
                )

        else {
            return []
        }


        let playerColumn =
            regChampColumn - 1


        var results:
            [FantasyCareerTitles] = []


        for row in rows.dropFirst(
            headerRowIndex + 1
        ) {

            let rawPlayer =
                value(
                    row,
                    playerColumn
                )


            if rawPlayer.isEmpty {
                break
            }


            let player =
                ManagerNameNormalizer
                    .normalize(
                        rawPlayer
                    )


            // Count actual Fantasy Championships
            // from the historical 1st-place column.

            let championships =
                yearlyFinishes.filter {

                    ManagerNameNormalizer
                        .normalize(
                            $0.firstPlace
                        ) == player

                }.count


            results.append(
                FantasyCareerTitles(

                    player:
                        player,

                    championships:
                        championships,

                    regularSeasonChampionships:
                        integer(
                            value(
                                row,
                                regChampColumn
                            )
                        ),

                    seasonHighPointsTitles:
                        integer(
                            value(
                                row,
                                highPointsColumn
                            )
                        )
                )
            )
        }


        return results
    }
}


// MARK: - Generic Helpers

private extension FantasyWinLossParser {

    static func index(
        of header: String,
        in row: [String],
        startingAt start: Int = 0
    ) -> Int? {

        guard start < row.count else {
            return nil
        }


        for column in start..<row.count {

            if clean(
                row[column]
            ) == clean(
                header
            ) {

                return column
            }
        }


        return nil
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
                .replacingOccurrences(
                    of: "-",
                    with: "0"
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

        SpreadsheetNumberParser
            .number(text) ?? 0
    }


    static func percentage(
        _ text: String
    ) -> Double {

        SpreadsheetNumberParser
            .percentage(text)
    }
}
