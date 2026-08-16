//
//  FantasyWinLossView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import SwiftUI

struct FantasyWinLossView: View {

    @StateObject private var viewModel =
        FantasyWinLossViewModel()

    var body: some View {

        Group {

            if viewModel.isLoading &&
                viewModel.data == nil {

                ProgressView(
                    "Loading Records..."
                )

            } else if let data =
                        viewModel.data {

                List {

                    ForEach(
                        data.seasons
                    ) { season in

                        Section {

                            ForEach(
                                season.players
                                    .sorted {
                                        if $0.wins == $1.wins {
                                            return $0.points >
                                                $1.points
                                        }

                                        return $0.wins >
                                            $1.wins
                                    }
                            ) { player in

                                HStack {

                                    VStack(
                                        alignment: .leading
                                    ) {

                                        Text(
                                            player.player
                                        )
                                        .fontWeight(
                                            .semibold
                                        )

                                        Text(
                                            "\(player.points, specifier: "%.1f") pts"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(
                                            .secondary
                                        )
                                    }

                                    Spacer()

                                    Text(
                                        "\(player.wins)-\(player.losses)"
                                    )
                                    .fontWeight(.bold)
                                }
                            }

                        } header: {

                            Text(
                                verbatim:
                                    String(
                                        season.year
                                    )
                            )
                        }
                    }
                }

            } else {

                ContentUnavailableView(
                    "Unable to Load Records",
                    systemImage:
                        "exclamationmark.triangle"
                )
            }
        }
        .navigationTitle(
            "Win-Loss Records"
        )
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
