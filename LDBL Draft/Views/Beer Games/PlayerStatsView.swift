//
//  PlayerStatsView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct PlayerStatsView: View {

    @StateObject private var viewModel =
        PlayerStatsViewModel()

    var body: some View {

        Group {

            if viewModel.isLoading &&
                viewModel.data == nil {

                ProgressView("Loading Player Stats...")

            } else if let data = viewModel.data {

                List {

                    Section("Overall Stats") {

                        ForEach(data.players) { player in

                            NavigationLink {

                                PlayerDetailView(
                                    playerName: player.name,
                                    data: data
                                )

                            } label: {

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text(player.name)
                                        .font(.headline)

                                    HStack {

                                        Text(
                                            "High: \(player.weeklyHighPoints, specifier: "%.1f")"
                                        )

                                        Spacer()

                                        Text(
                                            "Low: \(player.weeklyLowPoints, specifier: "%.1f")"
                                        )
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

            } else if !viewModel.errorMessage.isEmpty {

                ContentUnavailableView(
                    "Unable to Load Stats",
                    systemImage: "exclamationmark.triangle",
                    description: Text(
                        viewModel.errorMessage
                    )
                )
            }
        }
        .navigationTitle("Player Stats")
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
