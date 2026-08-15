//
//  AccumulatedPointsDetailView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct AccumulatedPointsDetailView: View {

    let player: AccumulatedBeerGamePoints

    private var seasons: [Int] {
        player.yearlyPoints.keys.sorted()
    }

    var body: some View {

        List {

            Section("Career") {

                HStack {

                    Text("Average Points")

                    Spacer()

                    Text(
                        player.averagePoints,
                        format:
                            .number.precision(
                                .fractionLength(1)
                            )
                    )
                    .fontWeight(.bold)
                }

                HStack {

                    Text("Total Points")

                    Spacer()

                    Text(
                        player.totalPoints,
                        format:
                            .number.precision(
                                .fractionLength(0)
                            )
                    )
                }

                HStack {

                    Text("Seasons Played")

                    Spacer()

                    Text(
                        "\(player.seasonsPlayed)"
                    )
                }
            }


            Section("Season Results") {

                ForEach(
                    seasons,
                    id: \.self
                ) { year in

                    HStack {

                        Text("\(year)")

                        Spacer()

                        if let points =
                            player.yearlyPoints[
                                year
                            ] {

                            Text(
                                points,
                                format:
                                    .number.precision(
                                        .fractionLength(0...1)
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
        .navigationTitle(player.player)
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}
