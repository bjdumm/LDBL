//
//  BeerGameEventResultsView.swift
//  LDBL Draft
//

import SwiftUI


struct BeerGameEventResultsView: View {

    let season:
        ScoreboardSeason

    let eventName:
        String


    // MARK: - Results

    private var results:
        [EventStanding] {

        season.entries
            .compactMap { entry in

                guard let event =
                        entry.events
                            .first(
                                where: {
                                    $0.event ==
                                    eventName
                                }
                            )
                else {
                    return nil
                }


                return EventStanding(
                    player:
                        ManagerNameNormalizer
                            .normalize(
                                entry.player
                            ),

                    result:
                        event.result,

                    points:
                        event.points
                )
            }
            .sorted {

                /*
                 Higher points represent
                 the better Beer Game
                 finish in the scoreboard.
                */

                if $0.points !=
                    $1.points {

                    return $0.points >
                        $1.points
                }


                return $0.player <
                    $1.player
            }
    }


    var body: some View {

        List {

            Section {

                ForEach(
                    Array(
                        results.enumerated()
                    ),
                    id: \.element.id
                ) { index, standing in

                    HStack(
                        spacing: 12
                    ) {

                        // MARK: Place

                        Text(
                            "#\(index + 1)"
                        )
                        .fontWeight(
                            .bold
                        )
                        .frame(
                            width: 35,
                            alignment: .leading
                        )


                        // MARK: Player / Result

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text(
                                standing.player
                            )
                            .fontWeight(
                                .semibold
                            )


                            if !standing.result
                                .isEmpty {

                                Text(
                                    standing.result
                                )
                                .font(
                                    .caption
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }


                        Spacer()


                        // MARK: Points

                        Text(
                            "\(standing.points) pts"
                        )
                        .fontWeight(
                            .semibold
                        )
                    }
                    .padding(
                        .vertical,
                        2
                    )
                }

            } header: {

                Text(
                    verbatim:
                        "\(season.year) Results"
                )
            }
        }
        .navigationTitle(
            eventName
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Event Standing

private struct EventStanding:
    Identifiable {

    let player:
        String

    let result:
        String

    let points:
        Int


    var id: String {

        player
    }
}
