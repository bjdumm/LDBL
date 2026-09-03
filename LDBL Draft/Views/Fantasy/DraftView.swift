import SwiftUI

struct DraftView: View {

    @EnvironmentObject
    var leagueData: LeagueDataStore


    var body: some View {

        Group {

            if
                leagueData.isLoading
                && leagueData.yearEndRosters.isEmpty {

                ProgressView(
                    "Loading Rosters..."
                )

            } else if
                leagueData.yearEndRosters.isEmpty {

                VStack(
                    spacing: 12
                ) {

                    Image(
                        systemName:
                            "person.3.sequence.fill"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(
                        .secondary
                    )


                    Text(
                        "No Year-End Rosters Available"
                    )
                    .font(.headline)


                    Text(
                        "Year-End Roster sheets will appear here automatically when they are added to the league spreadsheet."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                    .multilineTextAlignment(
                        .center
                    )
                }
                .padding()

            } else {

                List(
                    leagueData.yearEndRosters
                ) { season in

                    NavigationLink {

                        YearEndRosterSeasonView(
                            season: season
                        )

                    } label: {

                        Label(
                            String(
                                season.year
                            ),
                            systemImage:
                                "calendar"
                        )
                    }
                }
            }
        }
        .navigationTitle(
            "Draft"
        )
        .refreshable {

            await leagueData
                .refresh()
        }
    }
}


// MARK: - Season

private struct YearEndRosterSeasonView:
    View {

    let season:
        YearEndRosterSeason


    var body: some View {

        List(
            season.managers
        ) { manager in

            NavigationLink {

                YearEndRosterManagerView(
                    year:
                        season.year,
                    roster:
                        manager
                )

            } label: {

                HStack {

                    Text(
                        manager.manager
                    )


                    Spacer()


                    Text(
                        "\(manager.draftPicks.count + manager.acquiredPlayers.count) players"
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
        }
        .navigationTitle(
            "\(season.year) Rosters"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Manager

private struct YearEndRosterManagerView:
    View {

    let year: Int

    let roster:
        YearEndRosterManager


    var body: some View {

        List {

            // MARK: Draft Results

            if
                !roster.draftPicks.isEmpty {

                Section(
                    "Draft Results"
                ) {

                    ForEach(
                        roster.draftPicks
                    ) { pick in

                        DraftPlayerRow(
                            round:
                                pick.round,
                            player:
                                pick.player,
                            isKeeper:
                                pick.isKeeper,
                            isRemoved:
                                pick.isRemoved
                        )
                    }
                }
            }


            // MARK: Acquired

            if
                !roster.acquiredPlayers.isEmpty {

                Section(
                    "Acquired"
                ) {

                    ForEach(
                        roster.acquiredPlayers
                    ) { player in

                        AcquiredPlayerRow(
                            player:
                                player.player,
                            isKeeper:
                                player.isKeeper,
                            isRemoved:
                                player.isRemoved
                        )
                    }
                }
            }
        }
        .navigationTitle(
            roster.manager
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Draft Player Row

private struct DraftPlayerRow:
    View {

    let round: Int
    let player: String
    let isKeeper: Bool
    let isRemoved: Bool


    var body: some View {

        HStack(
            spacing: 10
        ) {

            Text(
                "Round \(round)"
            )
            .foregroundStyle(
                .secondary
            )
            .frame(
                width: 75,
                alignment:
                    .leading
            )


            Text(
                player
            )
            .fontWeight(
                isKeeper
                    ? .semibold
                    : .regular
            )
            .foregroundStyle(
                isRemoved
                    ? Color.red
                    : Color.primary
            )
            .strikethrough(
                isRemoved,
                color: .red
            )


            Spacer(
                minLength: 8
            )


            if isKeeper {

                KeeperBadge()
            }
        }
        .padding(
            .vertical,
            isKeeper
                ? 4
                : 0
        )
        .listRowBackground(
            isKeeper
                ? Color.yellow
                    .opacity(0.16)
                : Color.clear
        )
    }
}


// MARK: - Acquired Player Row

private struct AcquiredPlayerRow:
    View {

    let player: String
    let isKeeper: Bool
    let isRemoved: Bool


    var body: some View {

        HStack(
            spacing: 10
        ) {

            Text(
                player
            )
            .fontWeight(
                isKeeper
                    ? .semibold
                    : .regular
            )
            .foregroundStyle(
                isRemoved
                    ? Color.red
                    : Color.primary
            )
            .strikethrough(
                isRemoved,
                color: .red
            )


            Spacer(
                minLength: 8
            )


            if isKeeper {

                KeeperBadge()
            }
        }
        .padding(
            .vertical,
            isKeeper
                ? 4
                : 0
        )
        .listRowBackground(
            isKeeper
                ? Color.yellow
                    .opacity(0.16)
                : Color.clear
        )
    }
}


// MARK: - Keeper Badge

private struct KeeperBadge:
    View {

    var body: some View {

        Label(
            "KEEPER",
            systemImage:
                "star.fill"
        )
        .font(
            .caption2.bold()
        )
        .foregroundStyle(
            .black
        )
        .padding(
            .horizontal,
            9
        )
        .padding(
            .vertical,
            5
        )
        .background(
            .yellow,
            in:
                Capsule()
        )
    }
}
