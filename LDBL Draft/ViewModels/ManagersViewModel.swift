//
//  ManagersViewModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//
/*
import Foundation
import Combine

@MainActor
final class ManagersViewModel:
    ObservableObject {

    @Published var managers:
        [ManagerProfile] = []

    @Published var isLoading = false

    @Published var errorMessage = ""


    func load() async {

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {

            managers =
                try await
                SpreadsheetService.shared
                    .loadManagerProfiles()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}
*/
