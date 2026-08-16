//
//  AccumulatedEarningsView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct AccumulatedEarningsView: View {

    @StateObject private var viewModel =
        AccumulatedEarningsViewModel()

    private var rankedPlayers:
        [AccumulatedEarningsPlayer] {
        
            viewModel.players.sorted {
                $0.returnAmount >
                $1.returnAmount
            }
       
    }

    var body: some View {

        Group {

            if viewModel.isLoading &&
                viewModel.players.isEmpty {

                ProgressView(
                    "Loading Earnings..."
                )

            } else if
                !viewModel.errorMessage.isEmpty &&
                viewModel.players.isEmpty {

                ContentUnavailableView(
                    "Unable to Load Earnings",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(
                            viewModel.errorMessage
                        )
                )

            } else {

                List {

                    Section("Career Winnings") {

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
                                    .fontWeight(.bold)
                                    .frame(width: 35)

                                    Text(
                                        player.player
                                    )

                                    Spacer()

                                    Text(
                                        player.totalWinnings,
                                        format:
                                            .currency(
                                                code: "USD"
                                            )
                                            .precision(
                                                .fractionLength(0)
                                            )
                                    )
                                    .fontWeight(.semibold)
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
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
