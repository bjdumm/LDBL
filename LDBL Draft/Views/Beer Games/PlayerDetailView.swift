//
//  PlayerDetailView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct PlayerDetailView: View {

    let playerName: String
    let data: PlayerStatsSheetData

    private var overall: PlayerStats? {

        data.players.first {
            $0.name == playerName
        }
    }

    private var wins: PlayerGameWins? {

        data.wins.first {
            $0.name == playerName
        }
    }

    private var bests: PlayerGameScores? {

        data.personalBests.first {
            $0.name == playerName
        }
    }

    private var worsts: PlayerGameScores? {

        data.personalWorsts.first {
            $0.name == playerName
        }
    }

    var body: some View {

        List {

            if let overall {

                Section("Overall") {

                    statRow(
                        "Weekly High Points",
                        "\(overall.weeklyHighPoints)"
                    )

                    statRow(
                        "Weekly Low Points",
                        "\(overall.weeklyLowPoints)"
                    )

                    statRow(
                        "Beer Game 1st Places",
                        "\(overall.beerGameFirstPlaces)"
                    )

                    statRow(
                        "Beer Game Last Places",
                        "\(overall.beerGameLastPlaces)"
                    )

                    statRow(
                        "Beer Die Wins",
                        "\(overall.beerDieWins)"
                    )

                    statRow(
                        "Speedball Wins",
                        "\(overall.speedballWins)"
                    )
                }
            }

            if let wins {

                Section("Game Wins") {

                    statRow("Pong", "\(wins.pong)")
                    statRow("Cornhole", "\(wins.cornhole)")
                    statRow("Relays", "\(wins.relays)")
                    statRow("Quarter Pong", "\(wins.quarterPong)")
                    statRow("Flip Cup", "\(wins.flipCup)")
                    statRow("Darts", "\(wins.darts)")
                    statRow("Dizzy Bat", "\(wins.dizzyBat)")
                    statRow("Four Corners", "\(wins.fourCorners)")
                    statRow("Showcase", "\(wins.showcase)")
                }
            }

            if let bests {

                Section("Personal Bests") {

                    optionalStatRow("Pong", bests.pong)
                    optionalStatRow("Relays", bests.relays)
                    optionalStatRow(
                        "Quarter Pong",
                        bests.quarterPong
                    )
                    optionalStatRow(
                        "Flip Cup",
                        bests.flipCup
                    )
                    optionalStatRow(
                        "Dizzy Bat",
                        bests.dizzyBat
                    )
                    optionalStatRow(
                        "Four Corners",
                        bests.fourCorners
                    )
                    optionalStatRow(
                        "Showcase",
                        bests.showcase
                    )
                }
            }

            if let worsts {

                Section("Personal Worsts") {

                    optionalStatRow("Pong", worsts.pong)
                    optionalStatRow("Relays", worsts.relays)
                    optionalStatRow(
                        "Quarter Pong",
                        worsts.quarterPong
                    )
                    optionalStatRow(
                        "Flip Cup",
                        worsts.flipCup
                    )
                    optionalStatRow(
                        "Dizzy Bat",
                        worsts.dizzyBat
                    )
                    optionalStatRow(
                        "Four Corners",
                        worsts.fourCorners
                    )
                    optionalStatRow(
                        "Showcase",
                        worsts.showcase
                    )
                }
            }
        }
        .navigationTitle(playerName)
    }

    private func statRow(
        _ label: String,
        _ value: String
    ) -> some View {

        HStack {

            Text(label)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    private func optionalStatRow(
        _ label: String,
        _ value: Double?
    ) -> some View {

        if let value {

            statRow(
                label,
                value.formatted(
                    .number.precision(
                        .fractionLength(1)
                    )
                )
            )
        }
    }
}
