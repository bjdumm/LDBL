//
//  SeasonDetailsViewModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation
import Combine

@MainActor
final class SeasonDetailsViewModel:
    ObservableObject {

    @Published var seasons:
        [FantasySeasonDetails] = []

    @Published var isLoading = false

    @Published var errorMessage = ""

    func load() async {

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {

            seasons =
                try await
                SpreadsheetService.shared
                    .loadSeasonDetails()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
