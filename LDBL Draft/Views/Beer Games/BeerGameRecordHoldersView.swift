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

                            NavigationLink {

                                BeerGameAllTimeTopTenView(
                                    eventName: record.event,
                                    scoreboard: leagueData.scoreboard
                                )

                            } label: {

                                eventRecordRow(
                                    record
                                )
                            }
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

                VStack(spacing: 12) {

                    Image(
                        systemName: "chart.bar"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                    Text(
                        "No Data Available"
                    )
                    .font(.headline)

                    Text(
                        "There is currently no player data to display."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding()
            }
        }
        .navigationTitle(
            "Record Holders"
        )
        .refreshable {

            await leagueData.refresh()
        }
    }


    // MARK: - Dynamic Event Record

    @ViewBuilder
    private func eventRecordRow(
        _ record: BeerGameEventRecord
    ) -> some View {

        let liveRecord =
            bestPerformance(
                for: record.event
            )

        let player =
            liveRecord?.player ??
            ManagerNameNormalizer
                .normalize(
                    record.player
                )

        let result =
            liveRecord?.result ??
            record.score

        let year =
            liveRecord?.year ??
            record.season

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
                    result
                )
            }


            HStack {

                Text(
                    player
                )

                Spacer()

                Text(
                    verbatim:
                        String(
                            year
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


    private func bestPerformance(
        for eventName: String
    ) -> BeerGamePerformance? {

        let performances =
            BeerGamePerformanceRanking
                .performances(
                    eventName: eventName,
                    scoreboard: leagueData.scoreboard
                )

        let timed =
            BeerGamePerformanceRanking
                .isTimed(
                    performances
                )

        return BeerGamePerformanceRanking
            .sorted(
                performances,
                timed: timed
            )
            .first
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
