//
//  GamesAndRulesView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct GamesAndRulesView: View {

    @StateObject private var viewModel =
        GamesAndRulesViewModel()

    var body: some View {

        Group {

            if viewModel.isLoading &&
                viewModel.data == nil {

                ProgressView(
                    "Loading Rules..."
                )

            } else if let data =
                        viewModel.data {

                List {

                    if !data.eventDate.isEmpty {

                        Section {

                            Text(data.eventDate)
                                .font(.headline)
                        }
                    }


                    Section("General Rules") {

                        ForEach(
                            data.generalRules,
                            id: \.self
                        ) { rule in

                            Text(rule)
                        }
                    }


                    Section("Games") {

                        ForEach(data.games) { game in

                            NavigationLink {

                                BeerGameRuleDetailView(
                                    game: game
                                )

                            } label: {

                                VStack(
                                    alignment: .leading
                                ) {

                                    Text(
                                        "\(game.number) \(game.title)"
                                    )
                                    .fontWeight(
                                        .semibold
                                    )

                                    if !game
                                        .drinkingRequirement
                                        .isEmpty {

                                        Text(
                                            game.drinkingRequirement
                                        )
                                        .font(.caption)
                                        .foregroundStyle(
                                            .secondary
                                        )
                                    }
                                }
                            }
                        }
                    }


                    if !data.showcaseNotes.isEmpty {

                        Section(
                            "Showcase Event"
                        ) {

                            ForEach(
                                data.showcaseNotes,
                                id: \.self
                            ) { note in

                                Text(note)
                            }
                        }
                    }
                }

            } else {

                ContentUnavailableView(
                    "Unable to Load Rules",
                    systemImage:
                        "exclamationmark.triangle"
                )
            }
        }
        .navigationTitle("Games & Rules")
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
