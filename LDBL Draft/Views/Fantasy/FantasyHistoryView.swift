//
//  FantasyHistoryView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct FantasyHistoryView: View {

    var body: some View {

        NavigationStack {

            List {

                Section("Seasons") {

                    Text("2026 Season")
                    Text("2025 Season")
                    Text("2024 Season")
                }
            }
            .navigationTitle("Fantasy History")
        }
    }
}
