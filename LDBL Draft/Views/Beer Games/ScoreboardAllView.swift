//
//  ScoreboardAllView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.


import SwiftUI

struct ScoreboardAllView: View {

    @StateObject private var viewModel =
        ScoreboardAllViewModel()

    var body: some View {

        Group {

            if viewModel.isLoading &&
                viewModel.seasons.isEmpty {

                ProgressView(
                    "Loading Scoreboard..."
                )

            } else if !viewModel.errorMessage.isEmpty &&
                        viewModel.seasons.isEmpty {

                ContentUnavailableView(
                    "Unable to Load Scoreboard",
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

                    Section(
                        header: Text(verbatim: "\(season.year)")//"\(season.year)"
                    ) {

                        ForEach(
                            season.entries
                        ) { entry in

                            NavigationLink {

                                ScoreboardEntryView(
                                    entry: entry
                                )

                            } label: {

                                HStack {

                                    Text(
                                        "#\(entry.place)"
                                    )
                                    .fontWeight(.bold)
                                    .frame(width: 35)

                                    Text(entry.player)

                                    Spacer()

                                    Text(
                                        "\(entry.totalPoints) pts"
                                    )
                                    .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Scoreboard")
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
