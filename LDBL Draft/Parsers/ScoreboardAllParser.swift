import Foundation

struct ScoreboardAllParser {

    static func parse(
        rows: [[String]]
    ) -> [ScoreboardSeason] {

        var seasons: [ScoreboardSeason] = []

        let yearRows = rows.indices.filter { index in
            isYearRow(rows[index])
        }

        for (position, startIndex) in yearRows.enumerated() {

            guard let year =
                    Int(value(rows[startIndex], 0))
            else {
                continue
            }

            // Stop each season at the next year block OR at the
            // spreadsheet's trailing "ALL" summary section.
            //
            // Without this boundary the final season (for example 2026)
            // can accidentally absorb the ALL-time summary rows below it.
            // Those summary rows contain manager names in the event-result
            // columns, which is why the Top 10 screen could show a manager
            // name as both the player and the result.
            let nextYearIndex =
                position + 1 < yearRows.count
                    ? yearRows[position + 1]
                    : rows.count

            let allSummaryIndex =
                rows[startIndex..<rows.count]
                    .firstIndex { row in
                        value(row, 0)
                            .uppercased() == "ALL"
                    } ?? rows.count

            let endIndex =
                min(
                    nextYearIndex,
                    allSummaryIndex
                )

            let season =
                parseSeason(
                    year: year,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    rows: rows
                )

            // Ignore empty/preformatted future seasons.
            if !season.entries.isEmpty {
                seasons.append(season)
            }
        }

        return seasons.sorted {
            $0.year > $1.year
        }
    }
}


// MARK: - Private Helpers

private extension ScoreboardAllParser {

    struct UnrankedEntry {

        let player: String
        let events: [ScoreboardEventResult]
        let totalPoints: Int
    }


    static func parseSeason(
        year: Int,
        startIndex: Int,
        endIndex: Int,
        rows: [[String]]
    ) -> ScoreboardSeason {

        let eventHeaderRow =
            rows[startIndex]

        let eventColumns =
            findEventColumns(
                in: eventHeaderRow
            )

        var unrankedEntries:
            [UnrankedEntry] = []

        var participants: [String] = []

        let firstPlayerRow =
            startIndex + 2

        guard firstPlayerRow < endIndex else {

            return ScoreboardSeason(
                year: year,
                entries: []
            )
        }


        // MARK: - Read players

        for index in firstPlayerRow..<endIndex {

            let row = rows[index]

            // Real player rows in Scoreboard ALL have a numeric
            // position in column A and the manager name in column B.
            // Requiring both prevents labels/summary rows from ever being
            // interpreted as season results if the sheet grows later.
            guard Int(value(row, 0)) != nil else {
                continue
            }

            let rawPlayer =
                value(row, 1)

            guard !rawPlayer.isEmpty else {
                continue
            }

            let player =
                ManagerNameNormalizer
                    .normalize(rawPlayer)

            if !participants.contains(player) {
                participants.append(player)
            }

            var events:
                [ScoreboardEventResult] = []


            // MARK: Event Results

            for eventColumn in eventColumns {

                let eventName =
                    value(
                        eventHeaderRow,
                        eventColumn
                    )

                guard !eventName.isEmpty else {
                    continue
                }

                let result =
                    value(
                        row,
                        eventColumn
                    )

                let pointsText =
                    value(
                        row,
                        eventColumn + 1
                    )

                let points =
                    integer(pointsText)

                events.append(
                    ScoreboardEventResult(
                        event: eventName,
                        result: result,
                        points: points,
                        pointsEntered:
                            !pointsText.isEmpty &&
                            pointsText != "-"
                    )
                )
            }


            // MARK: Total Points

            let total =
                findTotal(
                    row: row,
                    headerRows: Array(
                        rows[
                            startIndex...min(
                                startIndex + 1,
                                rows.count - 1
                            )
                        ]
                    )
                )


            // A future season may already have
            // player names but no actual results.

            let hasResults =
                events.contains {
                    !$0.result.isEmpty ||
                    $0.points > 0
                }

            guard hasResults || total > 0 else {
                continue
            }


            unrankedEntries.append(
                UnrankedEntry(
                    player: player,
                    events: events,
                    totalPoints: total
                )
            )
        }


        // MARK: - Rank by Points

        let sortedEntries =
            unrankedEntries.sorted {

                if $0.totalPoints ==
                    $1.totalPoints {

                    // Stable fallback for ties.
                    return $0.player
                        .localizedCaseInsensitiveCompare(
                            $1.player
                        ) == .orderedAscending
                }

                return $0.totalPoints >
                    $1.totalPoints
            }


        var rankedEntries:
            [ScoreboardEntry] = []


        for (
            index,
            entry
        ) in sortedEntries.enumerated() {

            rankedEntries.append(
                ScoreboardEntry(
                    year: year,

                    // THIS is the real finish.
                    place: index + 1,

                    player: entry.player,

                    events:
                        entry.events,

                    totalPoints:
                        entry.totalPoints
                )
            )
        }


        return ScoreboardSeason(
            year: year,
            entries: rankedEntries,
            participants: participants
        )
    }


    // MARK: - Event Columns

    static func findEventColumns(
        in headerRow: [String]
    ) -> [Int] {

        var columns: [Int] = []

        // Event data starts in column C
        // and every event occupies two columns:
        //
        // Result | Award Points

        var column = 2

        while column <
                min(
                    headerRow.count,
                    24
                ) {

            if !value(
                headerRow,
                column
            ).isEmpty {

                columns.append(column)
            }

            column += 2
        }

        return columns
    }


    // MARK: - Find Total

    static func findTotal(
        row: [String],
        headerRows: [[String]]
    ) -> Int {

        for headerRow in headerRows {

            if let totalColumn =
                headerRow.firstIndex(
                    where: {

                        $0
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .uppercased()
                            == "TOTAL"
                    }
                ) {

                return integer(
                    value(
                        row,
                        totalColumn
                    )
                )
            }
        }

        return 0
    }


    // MARK: - Detect Year Rows

    static func isYearRow(
        _ row: [String]
    ) -> Bool {

        guard let year =
                Int(value(row, 0))
        else {
            return false
        }

        return year >= 2000 &&
               year <= 2100
    }


    // MARK: - Safe Cell Value

    static func value(
        _ row: [String],
        _ index: Int
    ) -> String {

        guard index >= 0,
              index < row.count
        else {
            return ""
        }

        return row[index]
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
    }


    // MARK: - Integer Conversion

    static func integer(
        _ text: String
    ) -> Int {

        let cleaned =
            text
                .replacingOccurrences(
                    of: ",",
                    with: ""
                )

        if let number =
            Int(cleaned) {

            return number
        }

        if let number =
            Double(cleaned) {

            return Int(number)
        }

        return 0
    }
}
