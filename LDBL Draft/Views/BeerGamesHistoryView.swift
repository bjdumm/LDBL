//
//  BeerGamesHistoryView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct BeerGamesHistoryView: View {

    var body: some View {

        List {

            Section("Past Events") {

                Text("2026 Beer Games")
                Text("2025 Beer Games")
                Text("2024 Beer Games")
            }
        }
        .navigationTitle("Game History")
    }
}
