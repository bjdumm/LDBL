//
//  GamesAndRulesView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct GamesAndRulesView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore

    var body: some View {

        Group {

            if leagueData.isLoading &&
                leagueData.gamesAndRules == nil {

                ProgressView(
                    "Loading Rules..."
                )

            } else if let data =
                        leagueData.gamesAndRules {

                List {

                    if !data.eventDate.isEmpty {

                        Section {

                            Text(
                                data.eventDate
                            )
                            .font(.headline)
                        }
                    }


                    if !data.generalRules.isEmpty {

                        Section(
                            "General Rules"
                        ) {

                            ForEach(
                                data.generalRules,
                                id: \.self
                            ) { rule in

                                Text(rule)
                            }
                        }
                    }


                    Section("Games") {

                        ForEach(
                            data.games
                        ) { game in

                            NavigationLink {

                                BeerGameRuleDetailView(
                                    game: game
                                )

                            } label: {

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
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
                                            game
                                                .drinkingRequirement
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


                    if !data
                        .showcaseNotes
                        .isEmpty {

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
                    "No Rules Available",
                    systemImage:
                        "book.closed"
                )
            }
        }
        .navigationTitle(
            "Games & Rules"
        )
        .refreshable {

            await leagueData.refresh()
        }
    }
}
