//
//  ScoreboardEntryView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI


struct ScoreboardEntryView: View {

    let entry:
        ScoreboardEntry

    let season:
        ScoreboardSeason


    var body: some View {

        List {

            // MARK: - Total Points

            Section {

                HStack {

                    Text(
                        "Total Points"
                    )


                    Spacer()


                    Text(
                        "\(entry.totalPoints)"
                    )
                    .font(
                        .title3
                    )
                    .fontWeight(
                        .bold
                    )
                }
            }


            // MARK: - Events

            Section(
                "Events"
            ) {

                ForEach(
                    entry.events
                ) { event in

                    NavigationLink {

                        BeerGameEventResultsView(
                            season: season,
                            eventName: event.event
                        )

                    } label: {

                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {

                            HStack {

                                Text(
                                    event.event
                                )
                                .fontWeight(
                                    .semibold
                                )


                                Spacer()


                                Text(
                                    "\(event.points) pts"
                                )
                            }


                            if !event.result
                                .isEmpty {

                                Text(
                                    event.result
                                )
                                .font(
                                    .caption
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(
            ManagerNameNormalizer
                .normalize(
                    entry.player
                )
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}
