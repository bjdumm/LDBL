//
//  GamesAndRulesViewModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation
import Combine

@MainActor
final class GamesAndRulesViewModel:
    ObservableObject {

    @Published var data:
        GamesRulesData?

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
                try await
                SpreadsheetService.shared
                    .loadGamesAndRules()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
