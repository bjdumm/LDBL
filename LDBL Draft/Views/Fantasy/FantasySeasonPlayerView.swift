//
//  FantasySeasonPlayerView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct FantasySeasonPlayerView: View {

    let player: FantasySeasonPlayer

    var body: some View {

        List {

            Section("Season Record") {

                HStack {

                    Text("Wins")

                    Spacer()

                    Text(
                        "\(player.wins)"
                    )
                    .fontWeight(.bold)
                }

                HStack {

                    Text("Losses")

                    Spacer()

                    Text(
                        "\(player.losses)"
                    )
                    .fontWeight(.bold)
                }

                HStack {

                    Text("Win %")

                    Spacer()

                    Text(
                        player.winPercentage,
                        format:
                            .percent.precision(
                                .fractionLength(1)
                            )
                    )
                    .fontWeight(.bold)
                }
            }


            Section("Weekly Results") {

                ForEach(
                    player.weeks
                ) { week in

                    HStack {

                        Text(
                            "Week \(week.week)"
                        )

                        Spacer()

                        Text(
                            "\(week.wins)-\(week.losses)"
                        )
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle(player.name)
    }
}
