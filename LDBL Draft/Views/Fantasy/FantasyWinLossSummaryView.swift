import SwiftUI

struct FantasyWinLossSummaryView: View {

    let data: FantasyWinLossData


    var body: some View {

        List {

            allTimeRecordsSection

            yearlyFinishesSection

            careerTitlesSection
        }
        .navigationTitle(
            "Career Summary"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Sections

private extension FantasyWinLossSummaryView {

    var allTimeRecordsSection:
        some View {

        Section(
            "All-Time Regular Season Records"
        ) {

            ForEach(
                data.careerRecords
            ) { player in

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    HStack {

                        Text(
                            player.player
                        )
                        .fontWeight(
                            .semibold
                        )


                        Spacer()


                        Text(
                            "\(player.wins)-\(player.losses)"
                        )
                        .fontWeight(
                            .bold
                        )
                    }


                    HStack {

                        Text("Win %")

                        Spacer()

                        Text(
                            verbatim:
                                AppNumberFormat.percent(
                                    player.winPercentage
                                )
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )


                    HStack {

                        Text("Points Per Game")

                        Spacer()

                        Text(
                            verbatim:
                                AppNumberFormat.decimal(
                                    player.pointsPerGame
                                )
                        )
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
    }


    var yearlyFinishesSection:
        some View {

        Section(
            "Season Finishes"
        ) {

            ForEach(
                data.yearlyFinishes
            ) { season in

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {

                    Text(
                        verbatim:
                            String(
                                season.year
                            )
                    )
                    .font(.headline)


                    finishRow(
                        "1st",
                        season.firstPlace
                    )


                    finishRow(
                        "2nd",
                        season.secondPlace
                    )


                    finishRow(
                        "3rd",
                        season.thirdPlace
                    )


                    Divider()


                    finishRow(
                        "Regular Season Champion",
                        season
                            .regularSeasonChampion
                    )
                }
                .padding(
                    .vertical,
                    4
                )
            }
        }
    }


    var careerTitlesSection:
        some View {

        Section(
            "Career Titles"
        ) {

            ForEach(
                data.careerTitles
            ) { player in

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        player.player
                    )
                    .fontWeight(
                        .semibold
                    )


                    HStack {

                        Text(
                            "Championships"
                        )

                        Spacer()

                        Text(
                            "\(player.championships)"
                        )
                        .fontWeight(
                            .bold
                        )
                    }


                    HStack {

                        Text(
                            "Regular Season Championships"
                        )

                        Spacer()

                        Text(
                            "\(player.regularSeasonChampionships)"
                        )
                        .fontWeight(
                            .bold
                        )
                    }


                    HStack {

                        Text(
                            "Season High Points"
                        )

                        Spacer()

                        Text(
                            "\(player.seasonHighPointsTitles)"
                        )
                        .fontWeight(
                            .bold
                        )
                    }
                }
                .padding(
                    .vertical,
                    4
                )
            }
        }
    }
        


    func finishRow(
        _ title: String,
        _ player: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(player)
                .fontWeight(
                    .semibold
                )
        }
    }
}
