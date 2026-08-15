//
//  PlayerStatsViewModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation
import Combine

@MainActor
final class PlayerStatsViewModel: ObservableObject {

    @Published var data: PlayerStatsSheetData?
    @Published var isLoading = false
    @Published var errorMessage = ""

    func load() async {

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {

            data =
                try await SpreadsheetService.shared
                    .loadPlayerStats()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
