import SwiftUI

struct BeerGameRecordHoldersView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore

    var body: some View {

        Group {

            if leagueData.isLoading &&
                leagueData
                    .beerGameRecordHolders == nil {

                ProgressView(
                    "Loading Records..."
                )

            } else if let data =
                        leagueData
                            .beerGameRecordHolders {

                List {

                    // MARK: - Event Records

                    Section(
                        "Event Records"
                    ) {

                        ForEach(
                            data.eventRecords
                        ) { record in

                            VStack(
                                alignment: .leading,
                                spacing: 5
                            ) {

                                HStack {

                                    Text(
                                        record.event
                                    )
                                    .fontWeight(
                                        .semibold
                                    )

                                    Spacer()

                                    Text(
                                        record.score
                                    )
                                }


                                HStack {

                                    Text(
                                        ManagerNameNormalizer
                                            .normalize(
                                                record.player
                                            )
                                    )

                                    Spacer()

                                    Text(
                                        verbatim:
                                            String(
                                                record.season
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


                    // MARK: - Championships

                    Section(
                        "Beer Game Championships"
                    ) {

                        ForEach(
                            data.championships
                                .sorted {
                                    $0.championships >
                                    $1.championships
                                }
                        ) { champion in

                            HStack {

                                Text(
                                    ManagerNameNormalizer
                                        .normalize(
                                            champion.player
                                        )
                                )

                                Spacer()

                                Text(
                                    "\(champion.championships)"
                                )
                                .fontWeight(
                                    .bold
                                )
                            }
                        }
                    }


                    // MARK: - Average Points

                    Section(
                        "Average Beer Game Points"
                    ) {

                        ForEach(
                            Array(
                                data
                                    .accumulatedPoints
                                    .sorted {
                                        $0.averagePoints >
                                        $1.averagePoints
                                    }
                                    .enumerated()
                            ),
                            id: \.element.id
                        ) { index, player in

                            NavigationLink {

                                AccumulatedPointsDetailView(
                                    player: player
                                )

                            } label: {

                                HStack {

                                    Text(
                                        "#\(index + 1)"
                                    )
                                    .fontWeight(
                                        .bold
                                    )
                                    .frame(
                                        width: 35
                                    )


                                    Text(
                                        ManagerNameNormalizer
                                            .normalize(
                                                player.player
                                            )
                                    )


                                    Spacer()


                                    Text(
                                        verbatim:
                                            formattedAverage(
                                                player.averagePoints
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

            } else {

                ContentUnavailableView(
                    "No Records Available",
                    systemImage:
                        "trophy"
                )
            }
        }
        .navigationTitle(
            "Record Holders"
        )
        .refreshable {

            await leagueData.refresh()
        }
    }


    // MARK: - Number Formatting

    private func formattedAverage(
        _ value: Double
    ) -> String {

        String(
            format: "%.1f",
            locale: Locale(
                identifier:
                    "en_US_POSIX"
            ),
            value
        )
    }
}
