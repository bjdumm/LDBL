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

                VStack(spacing: 12) {

                    Image(
                        systemName: "chart.bar"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                    Text(
                        "No Data Available"
                    )
                    .font(.headline)

                    Text(
                        "There is currently no player data to display."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding()
                
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
