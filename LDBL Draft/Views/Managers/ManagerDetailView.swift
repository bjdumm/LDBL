import SwiftUI

struct ManagerDetailView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore

    let manager: ManagerProfile


    var body: some View {

        List {

            fantasyCareerSection

            seasonHistorySection

            beerGamesCareerSection

            beerGamesHistorySection

            earningsSection

            yearlyEarningsSection
        }
        .navigationTitle(
            manager.name
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Sections

private extension ManagerDetailView {

    // MARK: Fantasy Career

    var fantasyCareerSection: some View {

        Section("Fantasy Career") {

            statRow(
                "Seasons",
                "\(manager.seasonsPlayed)"
            )


            statRow(
                "Championships",
                "\(manager.fantasyChampionships)"
            )


            statRow(
                "Beer Game Championships",
                "\(manager.beerGameChampionships)"
            )


            statRow(
                "Actual Record",
                "\(manager.actualCareerWins)-\(manager.actualCareerLosses)"
            )


            statRow(
                "All-Play Record",
                "\(manager.allPlayCareerWins)-\(manager.allPlayCareerLosses)"
            )


            statRow(
                "Actual Win %",
                AppNumberFormat.percent(
                    manager.actualCareerWinPercentage
                )
            )


            statRow(
                "All-Play Win %",
                AppNumberFormat.percent(
                    manager.allPlayCareerWinPercentage
                )
            )
        }
    }


    // MARK: Fantasy Season History

    var seasonHistorySection: some View {

        Section(
            "Fantasy Season History"
        ) {

            ForEach(
                manager.seasons
            ) { season in

                let actual =
                    manager
                        .actualFantasyRecords
                        .first {
                            $0.year ==
                                season.year
                        }


                let finish =
                    manager.fantasyFinish(
                        for: season.year
                    )


                let isChampion =
                    finish?.place == 1


                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    // MARK: Year

                    HStack(
                        spacing: 7
                    ) {

                        Text(
                            verbatim:
                                String(
                                    season.year
                                )
                        )
                        .font(
                            isChampion
                            ? .headline.bold()
                            : .headline
                        )


                        if isChampion {

                            Image(
                                systemName:
                                    "trophy.fill"
                            )
                            .foregroundStyle(
                                trophyColor(
                                    for: 1
                                )
                            )
                        }


                        Spacer()
                    }


                    // MARK: Actual

                    HStack {

                        Text("Actual")

                        Spacer()

                        if let actual {

                            Text(
                                "\(actual.wins)-\(actual.losses)"
                            )
                            .fontWeight(
                                .semibold
                            )

                        } else {

                            Text("—")
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }


                    // MARK: All-Play

                    HStack {

                        Text("All-Play")

                        Spacer()

                        Text(
                            "\(season.wins)-\(season.losses)"
                        )
                        .fontWeight(
                            .semibold
                        )
                    }


                    // MARK: Finish

                    HStack {

                        Text("Finish")

                        Spacer()

                        if let finish {

                            HStack(
                                spacing: 6
                            ) {

                                Image(
                                    systemName:
                                        "trophy.fill"
                                )
                                .foregroundStyle(
                                    trophyColor(
                                        for:
                                            finish.place
                                    )
                                )
                                .font(.caption)


                                Text(
                                    ordinal(
                                        finish.place
                                    )
                                )
                                .fontWeight(
                                    .semibold
                                )
                            }

                        } else {

                            Text("—")
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }


                    // MARK: Points

                    if let actual {

                        HStack {

                            Text("Points")

                            Spacer()

                            Text(
                                verbatim:
                                    AppNumberFormat
                                        .groupedDecimal(
                                            actual.points
                                        )
                            )
                            .fontWeight(
                                .semibold
                            )
                        }
                    }
                }
                .padding(
                    .vertical,
                    4
                )
            }
        }
    }


    // MARK: Beer Games Career

    var beerGamesCareerSection: some View {

        Section(
            "Beer Games Career"
        ) {

            statRow(
                "Seasons",
                "\(manager.beerGameSeasonsPlayed)"
            )


            statRow(
                "Total Points",
                "\(manager.beerGameTotalPoints)"
            )


            statRow(
                "Average Points",
                AppNumberFormat.decimal(
                    manager.averageBeerGamePoints
                )
            )


            if let bestFinish =
                manager.bestBeerGameFinish {

                statRow(
                    "Best Finish",
                    "#\(bestFinish)"
                )
            }


            statRow(
                "Championships",
                "\(manager.beerGameChampionships)"
            )
        }
    }


    // MARK: Beer Games History

    var beerGamesHistorySection: some View {

        Section(
            "Beer Games History"
        ) {

            if manager
                .beerGameResults
                .isEmpty {

                Text(
                    "No Beer Games history available."
                )
                .foregroundStyle(
                    .secondary
                )

            } else {

                ForEach(
                    manager.beerGameResults
                ) { result in

                    NavigationLink {

                        if let season =
                            leagueData
                                .scoreboard
                                .first(
                                    where: {
                                        $0.year ==
                                            result.year
                                    }
                                ) {

                            ScoreboardEntryView(
                                entry:
                                    result,
                                season:
                                    season
                            )

                        } else {

                            ScoreboardEntryView(
                                entry:
                                    result,
                                season:
                                    ScoreboardSeason(
                                        year:
                                            result.year,
                                        entries:
                                            [result]
                                    )
                            )
                        }

                    } label: {

                        HStack {

                            Text(
                                verbatim:
                                    String(
                                        result.year
                                    )
                            )


                            Spacer()


                            Text(
                                "#\(result.place)"
                            )
                            .fontWeight(
                                .semibold
                            )


                            Text(
                                "\(result.totalPoints) pts"
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


    // MARK: Career Earnings

    var earningsSection: some View {

        Section(
            "Career Earnings"
        ) {

            moneyRow(
                "Winnings",
                manager.totalWinnings
            )


            moneyRow(
                "Fees",
                manager.totalFees
            )


            moneyRow(
                "Return",
                manager.returnAmount
            )
        }
    }


    // MARK: Winnings by Season

    @ViewBuilder
    var yearlyEarningsSection: some View {

        if let earnings =
            manager.earnings {

            Section(
                "Winnings by Season"
            ) {

                ForEach(
                    earnings.yearlyWinnings
                ) { season in

                    HStack {

                        Text(
                            verbatim:
                                String(
                                    season.year
                                )
                        )


                        Spacer()


                        if let amount =
                            season.amount {

                            Text(
                                verbatim:
                                    AppNumberFormat
                                        .currency(
                                            amount
                                        )
                            )

                        } else {

                            Text("-")
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }
                }
            }
        }
    }


    // MARK: - Helpers

    func statRow(
        _ title: String,
        _ value: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(
                verbatim:
                    value
            )
            .fontWeight(
                .semibold
            )
        }
    }


    func moneyRow(
        _ title: String,
        _ amount: Double
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(
                verbatim:
                    AppNumberFormat
                        .currency(
                            amount
                        )
            )
            .fontWeight(
                .semibold
            )
        }
    }


    func ordinal(
        _ number: Int
    ) -> String {

        switch number {

        case 1:
            return "1st"

        case 2:
            return "2nd"

        case 3:
            return "3rd"

        default:
            return "\(number)th"
        }
    }


    func trophyColor(
        for place: Int
    ) -> Color {

        switch place {

        case 1:
            return .yellow

        case 2:
            return Color(
                red: 0.68,
                green: 0.68,
                blue: 0.72
            )

        case 3:
            return Color(
                red: 0.72,
                green: 0.45,
                blue: 0.20
            )

        default:
            return .secondary
        }
    }
}
