//
//  ScoreboardAllParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

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

            guard let year = Int(value(rows[startIndex], 0)) else {
                continue
            }

            let endIndex: Int

            if position + 1 < yearRows.count {
                endIndex = yearRows[position + 1]
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

private extension ScoreboardAllParser {

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

        var entries: [ScoreboardEntry] = []

        // First row = event names
        // Second row = Time/Award/etc.
        let firstPlayerRow = startIndex + 2

        guard firstPlayerRow < endIndex else {
            return ScoreboardSeason(
                year: year,
                entries: []
            )
        }

        for index in firstPlayerRow..<endIndex {

            let row = rows[index]

            let player = value(row, 1)

            guard !player.isEmpty else {
                continue
            }

            guard let place =
                    Int(value(row, 0))
            else {
                continue
            }

            var events: [ScoreboardEventResult] = []

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

                let points =
                    integer(
                        value(
                            row,
                            eventColumn + 1
                        )
                    )

                events.append(
                    ScoreboardEventResult(
                        event: eventName,
                        result: result,
                        points: points
                    )
                )
            }

            // TOTAL is column Y in the current sheet.
            // Searching makes us less dependent on that position.
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

            entries.append(
                ScoreboardEntry(
                    year: year,
                    place: place,
                    player: player,
                    events: events,
                    totalPoints: total
                )
            )
        }

        return ScoreboardSeason(
            year: year,
            entries: entries.sorted {
                $0.place < $1.place
            }
        )
    }


    static func findEventColumns(
        in headerRow: [String]
    ) -> [Int] {

        var columns: [Int] = []

        // Your event/result data begins at column C.
        var column = 2

        while column < min(headerRow.count, 24) {

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


    static func findTotal(
        row: [String],
        headerRows: [[String]]
    ) -> Int {

        for headerRow in headerRows {

            if let totalColumn =
                headerRow.firstIndex(
                    where: {
                        $0.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .uppercased() == "TOTAL"
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

        if let number = Int(value) {
            return number
        }

        if let number = Double(value) {
            return Int(number)
        }

        return 0
    }
}
