//
//  SeasonsDetailsView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct SeasonDetailsView: View {

    @StateObject private var viewModel =
        SeasonDetailsViewModel()

    var body: some View {

        Group {

            if viewModel.isLoading &&
                viewModel.seasons.isEmpty {

                ProgressView(
                    "Loading Seasons..."
                )

            } else if
                !viewModel.errorMessage.isEmpty &&
                viewModel.seasons.isEmpty {

                ContentUnavailableView(
                    "Unable to Load Season Details",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(
                            viewModel.errorMessage
                        )
                )

            } else {

                List(
                    viewModel.seasons
                ) { season in

                    NavigationLink {

                        FantasySeasonView(
                            season: season
                        )

                    } label: {

                        HStack {

                            Text(
                                verbatim:
                                    String(
                                        season.year
                                    )
                            )
                            .font(.headline)

                            Spacer()

                            Text(
                                "\(season.players.count) players"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Season Details")
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
