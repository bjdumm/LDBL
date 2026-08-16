//
//  FantasyWinLossViewModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import Foundation
import Combine

@MainActor
final class FantasyWinLossViewModel:
    ObservableObject {

    @Published var data:
        FantasyWinLossData?

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
                    .loadFantasyWinLoss()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
