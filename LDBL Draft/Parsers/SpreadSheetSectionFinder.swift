//
//  SpreadSheetSectionFinder.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct SpreadsheetSectionFinder {

    static func table(
        in rows: [[String]],
        requiredHeaders: [String],
        stopAtBlankKeyColumn keyHeader: String
    ) -> SpreadsheetTable? {

        guard let headerRowIndex =
                findHeaderRow(
                    in: rows,
                    requiredHeaders: requiredHeaders
                )
        else {
            return nil
        }

        let headers = rows[headerRowIndex]

        let table =
            SpreadsheetTable(
                headers: headers,
                rows: []
            )

        var dataRows: [[String]] = []

        var index =
            headerRowIndex + 1

        while index < rows.count {

            let row = rows[index]

            let key =
                table.string(
                    in: row,
                    header: keyHeader
                )

            if key.isEmpty {
                break
            }

            dataRows.append(row)

            index += 1
        }

        return SpreadsheetTable(
            headers: headers,
            rows: dataRows
        )
    }


    static func tableAfterSection(
        in rows: [[String]],
        sectionName: String,
        requiredHeaders: [String],
        stopAtBlankKeyColumn keyHeader: String
    ) -> SpreadsheetTable? {

        guard let sectionIndex =
                rows.firstIndex(where: { row in

                    row.contains {
                        normalize($0) ==
                        normalize(sectionName)
                    }
                })
        else {
            return nil
        }

        let remainingRows =
            Array(
                rows.dropFirst(sectionIndex + 1)
            )

        return table(
            in: remainingRows,
            requiredHeaders: requiredHeaders,
            stopAtBlankKeyColumn: keyHeader
        )
    }


    private static func findHeaderRow(
        in rows: [[String]],
        requiredHeaders: [String]
    ) -> Int? {

        rows.firstIndex { row in

            let normalizedCells =
                Set(
                    row.map {
                        normalize($0)
                    }
                )

            return requiredHeaders.allSatisfy {
                normalizedCells.contains(
                    normalize($0)
                )
            }
        }
    }


    private static func normalize(
        _ text: String
    ) -> String {

        text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }
}
