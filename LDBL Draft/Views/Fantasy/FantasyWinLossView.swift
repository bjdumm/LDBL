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

                    // MARK: - Permanent Top Section

                    Section {

                        NavigationLink {

                            FantasyWinLossSummaryView(
                                data: data
                            )

                        } label: {

                            Label(
                                "Career Summary",
                                systemImage:
                                    "trophy.fill"
                            )
                            .fontWeight(
                                .semibold
                            )
                        }
                    }


                    // MARK: - Individual Seasons

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
                                        alignment:
                                            .leading,
                                        spacing: 3
                                    ) {

                                        HStack(spacing: 8) {

                                            ManagerAvatarView(
                                                managerName: player.player,
                                                size: 30
                                            )

                                            Text(player.player)
                                                .fontWeight(.semibold)
                                        }


                                        Text(
                                            verbatim:
                                                "\(AppNumberFormat.decimal(player.points)) pts"
                                        )
                                        .font(
                                            .caption
                                        )
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
