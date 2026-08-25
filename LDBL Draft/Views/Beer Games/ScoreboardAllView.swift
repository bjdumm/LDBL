//
//  ScoreboardAllView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.


import SwiftUI

struct ScoreboardAllView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore

    var body: some View {

        Group {

            if leagueData.isLoading &&
                leagueData.scoreboard.isEmpty {

                ProgressView(
                    "Loading Scoreboard..."
                )

            } else {

                List(
                    leagueData.scoreboard
                ) { season in

                    Section {

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
                                    .fontWeight(
                                        .bold
                                    )
                                    .frame(
                                        width: 35
                                    )


                                    Text(
                                        ManagerNameNormalizer
                                            .normalize(
                                                entry.player
                                            )
                                    )


                                    Spacer()


                                    Text(
                                        "\(entry.totalPoints) pts"
                                    )
                                    .fontWeight(
                                        .semibold
                                    )
                                }
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
        }
        .navigationTitle(
            "Scoreboard"
        )
        .refreshable {

            await leagueData.refresh()
        }
    }
}
