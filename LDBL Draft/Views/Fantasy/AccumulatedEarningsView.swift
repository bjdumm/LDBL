//
//  AccumulatedEarningsView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct AccumulatedEarningsView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore


    private var rankedPlayers:
        [AccumulatedEarningsPlayer] {

        leagueData
            .accumulatedEarnings
            .sorted {
                $0.returnAmount >
                $1.returnAmount
            }
    }


    var body: some View {

        Group {

            if leagueData.isLoading &&
                leagueData
                    .accumulatedEarnings
                    .isEmpty {

                ProgressView(
                    "Loading Earnings..."
                )

            } else {

                List {

                    Section(
                        "Career Earnings"
                    ) {

                        ForEach(
                            Array(
                                rankedPlayers
                                    .enumerated()
                            ),
                            id: \.element.id
                        ) { index, player in

                            NavigationLink {

                                AccumulatedEarningsDetailView(
                                    player: player
                                )

                            } label: {

                                HStack {

                                    Text(
                                        "#\(index + 1)"
                                    )
                                    .fontWeight(
                                        .bold
                                    )
                                    .frame(
                                        width: 35
                                    )


                                    Text(
                                        player.player
                                    )


                                    Spacer()


                                    Text(
                                        player.returnAmount,
                                        format:
                                            .currency(
                                                code:
                                                    "USD"
                                            )
                                            .precision(
                                                .fractionLength(
                                                    0
                                                )
                                            )
                                    )
                                    .fontWeight(
                                        .semibold
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(
            "Accumulated Earnings"
        )
        .refreshable {

            await leagueData.refresh()
        }
    }
}
