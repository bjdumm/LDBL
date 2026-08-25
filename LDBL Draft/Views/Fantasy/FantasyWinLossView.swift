import SwiftUI

struct FantasyWinLossView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore

    var body: some View {

        Group {

            if leagueData.isLoading &&
                leagueData.fantasyWinLoss == nil {

                ProgressView(
                    "Loading Records..."
                )

            } else if let data =
                        leagueData.fantasyWinLoss {

                List {

                    ForEach(
                        data.seasons
                    ) { season in

                        Section {

                            ForEach(
                                season.players
                                    .sorted {

                                        if $0.wins ==
                                            $1.wins {

                                            return $0.points >
                                                $1.points
                                        }

                                        return $0.wins >
                                            $1.wins
                                    }
                            ) { player in

                                HStack {

                                    VStack(
                                        alignment: .leading,
                                        spacing: 3
                                    ) {

                                        Text(
                                            ManagerNameNormalizer
                                                .normalize(
                                                    player.player
                                                )
                                        )
                                        .fontWeight(
                                            .semibold
                                        )


                                        Text(
                                            "\(player.points, specifier: "%.1f") pts"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(
                                            .secondary
                                        )
                                    }


                                    Spacer()


                                    Text(
                                        "\(player.wins)-\(player.losses)"
                                    )
                                    .fontWeight(
                                        .bold
                                    )
                                }
                            }

                        } header: {

                            Text(
                                verbatim:
                                    String(
                                        season.year
                                    )
                            )
                        }
                    }
                }

            } else {

                ContentUnavailableView(
                    "No Records Available",
                    systemImage:
                        "chart.bar"
                )
            }
        }
        .navigationTitle(
            "Win-Loss Records"
        )
        .refreshable {

            await leagueData.refresh()
        }
    }
}
