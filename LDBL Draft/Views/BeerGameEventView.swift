//
//  BeerGameEventView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI
import Charts

struct BeerGameEventView: View {

    let title: String
    let keyPath: KeyPath<BeerGamePlayer, Double>

    private var rankedPlayers: [BeerGamePlayer] {

        BeerGamesData.players.sorted {
            $0[keyPath: keyPath] >
            $1[keyPath: keyPath]
        }
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                Chart(rankedPlayers) { player in

                    BarMark(
                        x: .value(
                            "Points",
                            player[keyPath: keyPath]
                        ),
                        y: .value(
                            "Player",
                            player.name
                        )
                    )
                    .annotation(position: .trailing) {

                        Text(
                            player[keyPath: keyPath],
                            format: .number.precision(
                                .fractionLength(1)
                            )
                        )
                        .font(.caption)
                    }
                }
                .frame(height: 400)

                VStack(spacing: 0) {

                    ForEach(
                        Array(rankedPlayers.enumerated()),
                        id: \.element.id
                    ) { index, player in

                        HStack {

                            Text("#\(index + 1)")
                                .fontWeight(.bold)
                                .frame(width: 40)

                            Text(player.name)

                            Spacer()

                            Text(
                                player[keyPath: keyPath],
                                format: .number.precision(
                                    .fractionLength(1)
                                )
                            )
                            .fontWeight(.semibold)
                        }
                        .padding()

                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
