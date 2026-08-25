import SwiftUI

struct ManagerDetailView: View {

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

    var fantasyCareerSection:
        some View {

        Section("Fantasy Career") {

            statRow(
                "Seasons",
                "\(manager.seasonsPlayed)"
            )


            statRow(
                "Actual Record",
                "\(manager.actualCareerWins)-\(manager.actualCareerLosses)"
            )


            statRow(
                "All-Play Record",
                "\(manager.allPlayCareerWins)-\(manager.allPlayCareerLosses)"
            )


            HStack {

                Text("Actual Win %")

                Spacer()

                Text(
                    manager
                        .actualCareerWinPercentage,
                    format:
                        .percent.precision(
                            .fractionLength(1)
                        )
                )
                .fontWeight(.semibold)
            }


            HStack {

                Text("All-Play Win %")

                Spacer()

                Text(
                    manager
                        .allPlayCareerWinPercentage,
                    format:
                        .percent.precision(
                            .fractionLength(1)
                        )
                )
                .fontWeight(.semibold)
            }
        }
    }


    var seasonHistorySection:
        some View {

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

                            Text("-")
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }


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


                    if let actual {

                        HStack {

                            Text("Points")

                            Spacer()

                            Text(
                                actual.points,
                                format:
                                    .number
                                    .precision(
                                        .fractionLength(
                                            1
                                        )
                                    )
                            )
                        }
                    }
                }
                .padding(
                    .vertical,
                    3
                )
            }
        }
    }


    var beerGamesCareerSection:
        some View {

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


            HStack {

                Text("Average Points")

                Spacer()

                Text(
                    manager
                        .averageBeerGamePoints,
                    format:
                        .number.precision(
                            .fractionLength(1)
                        )
                )
                .fontWeight(.semibold)
            }


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


    var beerGamesHistorySection:
        some View {

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

                        ScoreboardEntryView(
                            entry: result
                        )

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


    var earningsSection:
        some View {

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


    @ViewBuilder
    var yearlyEarningsSection:
        some View {

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
                                amount,
                                format:
                                    .currency(
                                        code:
                                            "USD"
                                    )
                                    .precision(
                                        .fractionLength(
                                            0
                                        )
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


    func statRow(
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


    func moneyRow(
        _ title: String,
        _ amount: Double
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(
                amount,
                format:
                    .currency(
                        code: "USD"
                    )
                    .precision(
                        .fractionLength(0)
                    )
            )
            .fontWeight(
                .semibold
            )
        }
    }
}
