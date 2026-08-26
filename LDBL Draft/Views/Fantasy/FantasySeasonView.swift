import SwiftUI

struct FantasySeasonView: View {

    let season: FantasySeasonDetails

    @EnvironmentObject var leagueData:
        LeagueDataStore


    // MARK: - Actual Records For This Season

    private var actualSeason:
        FantasyActualSeason? {

        leagueData
            .fantasyWinLoss?
            .seasons
            .first {
                $0.year == season.year
            }
    }


    // MARK: - League Champion

    private var championName:
        String? {

        leagueData
            .fantasyWinLoss?
            .yearlyFinishes
            .first {
                $0.year == season.year
            }
            .map {
                ManagerNameNormalizer
                    .normalize(
                        $0.firstPlace
                    )
            }
    }


    // MARK: - Sorted Players

    private var rankedPlayers:
        [FantasySeasonPlayer] {

        season.players.sorted {
            lhs,
            rhs in

            let lhsActual =
                actualRecord(
                    for: lhs.name
                )

            let rhsActual =
                actualRecord(
                    for: rhs.name
                )


            // Prefer actual records when available.

            if let lhsActual,
               let rhsActual {

                let lhsGames =
                    lhsActual.wins +
                    lhsActual.losses

                let rhsGames =
                    rhsActual.wins +
                    rhsActual.losses


                let lhsPct =
                    lhsGames > 0
                    ? Double(lhsActual.wins)
                        / Double(lhsGames)
                    : 0

                let rhsPct =
                    rhsGames > 0
                    ? Double(rhsActual.wins)
                        / Double(rhsGames)
                    : 0


                if lhsPct != rhsPct {
                    return lhsPct > rhsPct
                }


                if lhsActual.wins !=
                    rhsActual.wins {

                    return lhsActual.wins >
                        rhsActual.wins
                }


                // Use points as a sensible
                // secondary sort for tied records.

                return lhsActual.points >
                    rhsActual.points
            }


            // Fallback if actual data is missing.

            if lhs.wins != rhs.wins {
                return lhs.wins > rhs.wins
            }

            return lhs.losses <
                rhs.losses
        }
    }


    var body: some View {

        List {

            ForEach(
                rankedPlayers
            ) { player in

                let actual =
                    actualRecord(
                        for: player.name
                    )

                let isChampion =
                    isLeagueChampion(
                        player.name
                    )


                NavigationLink {

                    FantasySeasonPlayerView(
                        player: player,
                        actualRecord: actual,
                        isChampion: isChampion
                    )

                } label: {

                    HStack(spacing: 10) {

                        ManagerAvatarView(
                            managerName:
                                player.name,
                            size: 34
                        )


                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            HStack(
                                spacing: 5
                            ) {

                                Text(
                                    ManagerNameNormalizer
                                        .normalize(
                                            player.name
                                        )
                                )
                                .fontWeight(
                                    .semibold
                                )


                                if isChampion {

                                    Image(
                                        systemName:
                                            "trophy.fill"
                                    )
                                    .foregroundStyle(
                                        .yellow
                                    )
                                    .font(
                                        .caption
                                    )
                                }
                            }


                            if let actual {

                                Text(
                                    verbatim:
                                        "\(AppNumberFormat.decimal(actual.points)) pts"
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }


                        Spacer()


                        if let actual {

                            Text(
                                "\(actual.wins)-\(actual.losses)"
                            )
                            .fontWeight(
                                .bold
                            )

                        } else {

                            Text("-")
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }
                    .padding(
                        .vertical,
                        3
                    )
                }
            }
        }
        .navigationTitle(
            Text(
                verbatim:
                    String(
                        season.year
                    )
            )
        )
    }
}


// MARK: - Helpers

private extension FantasySeasonView {

    func actualRecord(
        for managerName: String
    ) -> FantasyActualRecord? {

        let normalized =
            ManagerNameNormalizer
                .normalize(
                    managerName
                )


        return actualSeason?
            .players
            .first {

                ManagerNameNormalizer
                    .normalize(
                        $0.player
                    ) == normalized
            }
    }


    func isLeagueChampion(
        _ managerName: String
    ) -> Bool {

        guard let championName else {
            return false
        }

        return ManagerNameNormalizer
            .normalize(
                managerName
            ) == championName
    }
}
