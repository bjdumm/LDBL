//
//  AccumulatedEarningsViewModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation
import Combine

@MainActor
final class AccumulatedEarningsViewModel:
    ObservableObject {

    @Published var players:
        [AccumulatedEarningsPlayer] = []

    @Published var isLoading = false

    @Published var errorMessage = ""

    func load() async {

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {

            players =
                try await SpreadsheetService.shared
                    .loadAccumulatedEarnings()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
