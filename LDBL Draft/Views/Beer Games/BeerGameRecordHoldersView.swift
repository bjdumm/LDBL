//
//  BeerGameRecordHoldersView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct BeerGameRecordHoldersView: View {

    @StateObject private var viewModel =
        BeerGameRecordHoldersViewModel()

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

                    Section("Event Records") {

                        ForEach(
                            data.eventRecords
                        ) { record in

                            VStack(
                                alignment: .leading,
                                spacing: 5
                            ) {

                                HStack {

                                    Text(record.event)
                                        .fontWeight(
                                            .semibold
                                        )

                                    Spacer()

                                    Text(record.score)
                                }

                                HStack {

                                    Text(record.player)

                                    Spacer()

                                    Text("\(record.season)")
                                }
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                            .padding(
                                .vertical,
                                3
                            )
                        }
                    }


                    Section(
                        "Beer Game Championships"
                    ) {

                        ForEach(
                            data.championships
                                .sorted {
                                    $0.championships >
                                    $1.championships
                                }
                        ) { champion in

                            HStack {

                                Text(
                                    champion.player
                                )

                                Spacer()

                                Text(
                                    "\(champion.championships)"
                                )
                                .fontWeight(.bold)
                            }
                        }
                    }
                    
                    Section("Average Beer Game Points") {

                        let rankings =
                            data.accumulatedPoints.sorted {
                                $0.averagePoints >
                                $1.averagePoints
                            }

                        ForEach(
                            Array(rankings.enumerated()),
                            id: \.element.id
                        ) { index, player in

                            NavigationLink {

                                AccumulatedPointsDetailView(
                                    player: player
                                )

                            } label: {

                                HStack {

                                    Text("#\(index + 1)")
                                        .fontWeight(.bold)
                                        .frame(width: 35)

                                    Text(player.player)

                                    Spacer()

                                    Text(
                                        player.averagePoints,
                                        format: .number.precision(
                                            .fractionLength(1)
                                        )
                                    )
                                    .fontWeight(.semibold)
                                }
                            }
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
        .navigationTitle("Record Holders")
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
