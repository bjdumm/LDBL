//
//  SpreadSheetTestView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct SpreadsheetTestView: View {

    @State private var rows: [[String]] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {

        NavigationStack {

            Group {

                if isLoading {

                    ProgressView("Loading Google Sheet...")

                } else if !errorMessage.isEmpty {

                    VStack(spacing: 15) {

                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)

                        Text("Error")
                            .font(.headline)

                        Text(errorMessage)
                            .multilineTextAlignment(.center)

                        Button("Try Again") {
                            Task {
                                await loadSheet()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()

                } else {

                    List {

                        ForEach(
                            Array(rows.enumerated()),
                            id: \.offset
                        ) { rowIndex, row in

                            VStack(
                                alignment: .leading,
                                spacing: 5
                            ) {

                                Text("Row \(rowIndex + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                ForEach(
                                    Array(row.enumerated()),
                                    id: \.offset
                                ) { columnIndex, value in

                                    if !value.isEmpty {

                                        Text(
                                            "Column \(columnIndex + 1): \(value)"
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sheet Test")
            .task {
                await loadSheet()
            }
            .refreshable {
                await loadSheet()
            }
        }
    }

    private func loadSheet() async {

        isLoading = true
        errorMessage = ""

        do {

            rows =
                try await SpreadsheetService.shared
                    .fetchSheet(
                        named: "Player Stats"
                    )

            print("Received \(rows.count) rows")

        } catch {

            print("Spreadsheet error:", error)

            errorMessage =
                error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    SpreadsheetTestView()
}
