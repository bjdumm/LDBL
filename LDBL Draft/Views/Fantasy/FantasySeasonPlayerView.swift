import SwiftUI

struct FantasySeasonPlayerView: View {

    let player:
        FantasySeasonPlayer

    let actualRecord:
        FantasyActualRecord?

    let isChampion: Bool


    var body: some View {

        List {

            // MARK: - Actual Record

            Section(
                "Actual Fantasy Record"
            ) {

                if let actualRecord {

                    if isChampion {

                        HStack {

                            Label(
                                "League Champion",
                                systemImage:
                                    "trophy.fill"
                            )
                            .fontWeight(
                                .semibold
                            )
                            .foregroundStyle(
                                .yellow
                            )

                            Spacer()
                        }
                    }


                    statRow(
                        "Wins",
                        "\(actualRecord.wins)"
                    )


                    statRow(
                        "Losses",
                        "\(actualRecord.losses)"
                    )


                    HStack {

                        Text("Win %")

                        Spacer()

                        Text(
                            verbatim:
                                AppNumberFormat.percent(
                                    actualRecord.winPercentage
                                )
                        )
                        .fontWeight(.semibold)
                    }


                    HStack {

                        Text(
                            "Points Scored"
                        )

                        Spacer()

                        Text(
                            verbatim:
                                AppNumberFormat.decimal(
                                    actualRecord.points
                                )
                        )
                        .fontWeight(.semibold)
                    }

                } else {

                    Text(
                        "Actual record unavailable."
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }


            // MARK: - All-Play Record

            Section(
                "All-Play Record"
            ) {

                statRow(
                    "Wins",
                    "\(player.wins)"
                )


                statRow(
                    "Losses",
                    "\(player.losses)"
                )


                HStack {

                    Text("Win %")

                    Spacer()

                    Text(
                        verbatim:
                            AppNumberFormat.percent(
                                player.winPercentage
                            )
                    )
                    .fontWeight(.semibold)
                    
                }
            }


            // MARK: - Weekly All-Play Results

            Section(
                "Weekly All-Play Results"
            ) {

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
                        .fontWeight(
                            .semibold
                        )
                    }
                }
            }
        }
        .navigationTitle(
            ManagerNameNormalizer
                .normalize(
                    player.name
                )
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }


    // MARK: - Stat Row

    private func statRow(
        _ title: String,
        _ value: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(
                    .semibold
                )
        }
    }
}
