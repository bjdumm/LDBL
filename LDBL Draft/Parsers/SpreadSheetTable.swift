//
//  SpreadSheetTable.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct SpreadsheetTable {

    let headers: [String]
    let rows: [[String]]

    // Maps normalized header names to their column indexes.
    private let headerIndexes: [String: Int]

    init(
        headers: [String],
        rows: [[String]]
    ) {

        self.headers = headers
        self.rows = rows

        var indexes: [String: Int] = [:]

        for (index, header) in headers.enumerated() {

            let normalized =
                Self.normalize(header)

            if !normalized.isEmpty {
                indexes[normalized] = index
            }
        }

        self.headerIndexes = indexes
    }


    func string(
        in row: [String],
        header: String
    ) -> String {

        guard let index =
                headerIndexes[
                    Self.normalize(header)
                ],
              index < row.count
        else {
            return ""
        }

        return row[index]
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }


    func int(
        in row: [String],
        header: String
    ) -> Int {

        let text = string(
            in: row,
            header: header
        )

        guard !text.isEmpty,
              text != "-"
        else {
            return 0
        }

        return Int(text) ?? 0
    }


    func double(
        in row: [String],
        header: String
    ) -> Double {

        let text = string(
            in: row,
            header: header
        )

        guard !text.isEmpty,
              text != "-"
        else {
            return 0
        }

        return Double(text) ?? 0
    }


    func optionalDouble(
        in row: [String],
        header: String
    ) -> Double? {

        let text = string(
            in: row,
            header: header
        )

        guard !text.isEmpty,
              text != "-"
        else {
            return nil
        }

        return Double(text)
    }


    func containsHeader(
        _ header: String
    ) -> Bool {

        headerIndexes[
            Self.normalize(header)
        ] != nil
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
