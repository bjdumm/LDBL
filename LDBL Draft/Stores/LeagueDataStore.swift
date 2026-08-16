//
//  LeagueDataStore.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import Foundation
import Combine

@MainActor
final class LeagueDataStore: ObservableObject {

    // MARK: - Fantasy

    @Published var seasonDetails:
        [FantasySeasonDetails] = []

    @Published var fantasyWinLoss:
        FantasyWinLossData?

    @Published var accumulatedEarnings:
        [AccumulatedEarningsPlayer] = []


    // MARK: - Beer Games

    @Published var scoreboard:
        [ScoreboardSeason] = []

    @Published var beerGameRecordHolders:
        BeerGameRecordHoldersData?

    @Published var gamesAndRules:
        GamesRulesData?


    // MARK: - Managers

    @Published var managers:
        [ManagerProfile] = []


    // MARK: - State

    @Published var isLoading = false
    @Published var errorMessage = ""

    private var hasLoaded = false


    // MARK: - Load

    func loadIfNeeded() async {

        guard !hasLoaded else {
            return
        }

        await refresh()
    }


    func refresh() async {

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = ""

        defer {
            isLoading = false
        }

        do {

            async let seasonDetailsRequest =
                SpreadsheetService.shared
                    .loadSeasonDetails()

            async let fantasyWinLossRequest =
                SpreadsheetService.shared
                    .loadFantasyWinLoss()

            async let earningsRequest =
                SpreadsheetService.shared
                    .loadAccumulatedEarnings()

            async let scoreboardRequest =
                SpreadsheetService.shared
                    .loadScoreboardAll()

            async let recordsRequest =
                SpreadsheetService.shared
                    .loadBeerGameRecordHolders()

            async let rulesRequest =
                SpreadsheetService.shared
                    .loadGamesAndRules()


            let (
                loadedSeasonDetails,
                loadedWinLoss,
                loadedEarnings,
                loadedScoreboard,
                loadedRecords,
                loadedRules
            ) = try await (
                seasonDetailsRequest,
                fantasyWinLossRequest,
                earningsRequest,
                scoreboardRequest,
                recordsRequest,
                rulesRequest
            )


            seasonDetails =
                loadedSeasonDetails

            fantasyWinLoss =
                loadedWinLoss

            accumulatedEarnings =
                loadedEarnings

            scoreboard =
                loadedScoreboard

            beerGameRecordHolders =
                loadedRecords

            gamesAndRules =
                loadedRules


            managers =
                buildManagerProfiles(
                    seasons:
                        loadedSeasonDetails,

                    actualRecords:
                        loadedWinLoss,

                    earnings:
                        loadedEarnings,

                    scoreboard:
                        loadedScoreboard
                )


            hasLoaded = true

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }
}

private extension LeagueDataStore {

    func buildManagerProfiles(
        seasons: [FantasySeasonDetails],
        actualRecords: FantasyWinLossData,
        earnings: [AccumulatedEarningsPlayer],
        scoreboard: [ScoreboardSeason]
    ) -> [ManagerProfile] {

        var names = Set<String>()


        // MARK: Fantasy All-Play Names

        for season in seasons {

            for player in season.players {

                names.insert(
                    ManagerNameNormalizer
                        .normalize(
                            player.name
                        )
                )
            }
        }


        // MARK: Actual Fantasy Records

        for season in actualRecords.seasons {

            for player in season.players {

                names.insert(
                    ManagerNameNormalizer
                        .normalize(
                            player.player
                        )
                )
            }
        }


        // MARK: Earnings

        for player in earnings {

            names.insert(
                ManagerNameNormalizer
                    .normalize(
                        player.player
                    )
            )
        }


        // MARK: Beer Games

        for season in scoreboard {

            for entry in season.entries {

                names.insert(
                    ManagerNameNormalizer
                        .normalize(
                            entry.player
                        )
                )
            }
        }


        return names
            .map { name in

                buildManagerProfile(
                    name: name,
                    seasons: seasons,
                    actualRecords:
                        actualRecords,
                    earnings: earnings,
                    scoreboard: scoreboard
                )
            }
            .sorted {
                $0.name < $1.name
            }
    }


    func buildManagerProfile(
        name: String,
        seasons: [FantasySeasonDetails],
        actualRecords: FantasyWinLossData,
        earnings: [AccumulatedEarningsPlayer],
        scoreboard: [ScoreboardSeason]
    ) -> ManagerProfile {

        // MARK: All-Play Records

        var managerSeasons:
            [ManagerSeasonStats] = []

        for season in seasons {

            if let player =
                season.players.first(
                    where: {

                        ManagerNameNormalizer
                            .normalize(
                                $0.name
                            ) == name
                    }
                ) {

                managerSeasons.append(
                    ManagerSeasonStats(
                        manager: name,
                        year: season.year,
                        wins: player.wins,
                        losses: player.losses
                    )
                )
            }
        }


        // MARK: Actual Records

        let managerActualRecords =
            actualRecords.seasons
                .flatMap {
                    $0.players
                }
                .filter {

                    ManagerNameNormalizer
                        .normalize(
                            $0.player
                        ) == name
                }
                .sorted {
                    $0.year > $1.year
                }


        // MARK: Earnings

        let managerEarnings =
            earnings.first {

                ManagerNameNormalizer
                    .normalize(
                        $0.player
                    ) == name
            }


        // MARK: Beer Games

        let beerGameResults =
            scoreboard
                .flatMap {
                    $0.entries
                }
                .filter {

                    ManagerNameNormalizer
                        .normalize(
                            $0.player
                        ) == name
                }
                .sorted {
                    $0.year > $1.year
                }


        return ManagerProfile(
            name: name,

            seasons:
                managerSeasons.sorted {
                    $0.year > $1.year
                },

            earnings:
                managerEarnings,

            beerGameResults:
                beerGameResults,

            actualFantasyRecords:
                managerActualRecords
        )
    }
}
