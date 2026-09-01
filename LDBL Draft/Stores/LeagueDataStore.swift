//
//  LeagueDataStore.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import Foundation
import Combine


@MainActor
final class LeagueDataStore:
    ObservableObject {

    // MARK: - Fantasy

    @Published var seasonDetails:
        [FantasySeasonDetails] = []

    @Published var fantasyWinLoss:
        FantasyWinLossData?

    @Published var accumulatedEarnings:
        [AccumulatedEarningsPlayer] = []

    @Published var yearEndRosters:
        [YearEndRosterSeason] = []


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


    // MARK: - Loading State

    @Published var isLoading = false

    @Published var isRefreshing = false

    @Published var errorMessage = ""

    @Published var lastUpdated:
        Date?


    private var hasLoaded = false


    /*
     Automatically fetch Google again
     if the saved data is older than
     12 hours.

     Pull-to-refresh ignores this.
    */

    private let automaticRefreshInterval:
        TimeInterval =
            12 * 60 * 60


    // MARK: - Initial App Load

    func loadIfNeeded() async {

        guard !hasLoaded else {
            return
        }


        hasLoaded = true


        var loadedCache = false


        // MARK: Load Cache First

        do {

            if let cached =
                try await
                    LeagueDataCache
                        .shared
                        .load() {

                let payload =
                    try SpreadsheetService
                        .shared
                        .parseLeagueData(
                            from:
                                cached.sheets
                        )


                apply(
                    payload
                )


                lastUpdated =
                    cached.lastUpdated


                loadedCache = true


                print(
                    "Loaded league data from local cache."
                )
            }

        } catch {

            print(
                "Unable to load league cache:",
                error.localizedDescription
            )
        }


        /*
         If there's no cache at all,
         show the loading indicator.

         If we DO have cached data,
         leave the interface visible.
        */

        if !loadedCache {

            isLoading = true
        }


        // MARK: Decide Whether Google Is Needed

        if shouldAutomaticallyRefresh() {

            await refreshFromGoogle(
                showLoading:
                    !loadedCache
            )

        } else {

            isLoading = false


            print(
                "Cached league data is still fresh."
            )
        }
    }


    // MARK: - Pull To Refresh

    /*
     Existing views already call:

     await leagueData.refresh()

     This ALWAYS fetches Google,
     regardless of cache age.
    */

    func refresh() async {

        await refreshFromGoogle(
            showLoading: false
        )
    }


    // MARK: - Google Refresh

    private func refreshFromGoogle(
        showLoading: Bool
    ) async {

        guard !isRefreshing else {
            return
        }


        isRefreshing = true

        errorMessage = ""


        if showLoading {

            isLoading = true
        }


        defer {

            isRefreshing = false

            isLoading = false
        }


        do {

            let freshData =
                try await
                    SpreadsheetService
                        .shared
                        .fetchLeagueData()


            // MARK: Update UI

            apply(
                freshData.payload
            )


            // MARK: Save Cache

            do {

                try await
                    LeagueDataCache
                        .shared
                        .save(
                            sheets:
                                freshData
                                    .rawSheets
                        )


                lastUpdated =
                    Date()


                print(
                    "Saved fresh league data to local cache."
                )

            } catch {

                /*
                 Don't fail the UI merely
                 because saving the cache
                 failed.
                */

                print(
                    "Unable to save league cache:",
                    error.localizedDescription
                )
            }


            print(
                "League data refresh complete."
            )

        } catch {

            /*
             IMPORTANT:

             We do NOT clear existing data.

             If cached data was already
             displayed, it remains displayed.
            */

            errorMessage =
                error.localizedDescription


            print(
                "League refresh failed:",
                error.localizedDescription
            )
        }
    }


    // MARK: - Cache Freshness

    private func shouldAutomaticallyRefresh()
        -> Bool {

        // Older caches created before Draft/Year-End Rosters existed
        // should be upgraded immediately instead of waiting 12 hours.
        if yearEndRosters.isEmpty {
            return true
        }

        guard let lastUpdated
        else {
            return true
        }


        let age =
            Date()
                .timeIntervalSince(
                    lastUpdated
                )


        return age >=
            automaticRefreshInterval
    }


    // MARK: - Apply Loaded Data

    private func apply(
        _ data: LeagueDataPayload
    ) {

        // Fantasy

        seasonDetails =
            data.seasonDetails


        fantasyWinLoss =
            data.fantasyWinLoss


        accumulatedEarnings =
            data.accumulatedEarnings

        yearEndRosters =
            data.yearEndRosters


        // Beer Games

        scoreboard =
            data.scoreboard


        beerGameRecordHolders =
            data.beerGameRecordHolders


        gamesAndRules =
            data.gamesAndRules


        // Managers

        managers =
            buildManagerProfiles(
                seasons:
                    data.seasonDetails,

                actualRecords:
                    data.fantasyWinLoss,

                earnings:
                    data.accumulatedEarnings,

                scoreboard:
                    data.scoreboard
            )
    }
}


// MARK: - Manager Profiles

private extension LeagueDataStore {

    func buildManagerProfiles(
        seasons:
            [FantasySeasonDetails],

        actualRecords:
            FantasyWinLossData,

        earnings:
            [AccumulatedEarningsPlayer],

        scoreboard:
            [ScoreboardSeason]

    ) -> [ManagerProfile] {


        var names =
            Set<String>()


        // MARK: Fantasy Names

        for season in seasons {

            for player in
                season.players {

                names.insert(

                    ManagerNameNormalizer
                        .normalize(
                            player.name
                        )
                )
            }
        }


        // MARK: Actual Fantasy Names

        for season in
            actualRecords.seasons {

            for player in
                season.players {

                names.insert(

                    ManagerNameNormalizer
                        .normalize(
                            player.player
                        )
                )
            }
        }


        // MARK: Earnings Names

        for player in earnings {

            names.insert(

                ManagerNameNormalizer
                    .normalize(
                        player.player
                    )
            )
        }


        // MARK: Beer Games Names

        for season in scoreboard {

            for entry in
                season.entries {

                names.insert(

                    ManagerNameNormalizer
                        .normalize(
                            entry.player
                        )
                )
            }
        }


        // MARK: Remove Non-Managers

        names.remove("Eagler")

        names.remove("Handy")

        names.remove("HANDY")

        names.remove("Jim")


        // MARK: Build Profiles

        return names
            .map { name in

                buildManagerProfile(
                    name:
                        name,

                    seasons:
                        seasons,

                    actualRecords:
                        actualRecords,

                    earnings:
                        earnings,

                    scoreboard:
                        scoreboard
                )
            }
            .sorted {

                $0.name <
                $1.name
            }
    }


    // MARK: - Build One Manager

    func buildManagerProfile(
        name: String,

        seasons:
            [FantasySeasonDetails],

        actualRecords:
            FantasyWinLossData,

        earnings:
            [AccumulatedEarningsPlayer],

        scoreboard:
            [ScoreboardSeason]

    ) -> ManagerProfile {


        // MARK: All-Play Records

        var managerSeasons:
            [ManagerSeasonStats] = []


        for season in seasons {

            if let player =
                season.players
                    .first(
                        where: {

                            ManagerNameNormalizer
                                .normalize(
                                    $0.name
                                ) == name
                        }
                    ) {

                managerSeasons.append(

                    ManagerSeasonStats(

                        manager:
                            name,

                        year:
                            season.year,

                        wins:
                            player.wins,

                        losses:
                            player.losses
                    )
                )
            }
        }


        // MARK: Actual Records

        let managerActualRecords =

            actualRecords
                .seasons
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

                    $0.year >
                    $1.year
                }


        // MARK: Fantasy Finishes

        var managerFantasyFinishes:
            [ManagerFantasyFinish] = []


        for finish in
            actualRecords
                .yearlyFinishes {

            let firstPlace =

                ManagerNameNormalizer
                    .normalize(
                        finish.firstPlace
                    )


            let secondPlace =

                ManagerNameNormalizer
                    .normalize(
                        finish.secondPlace
                    )


            let thirdPlace =

                ManagerNameNormalizer
                    .normalize(
                        finish.thirdPlace
                    )


            if firstPlace == name {

                managerFantasyFinishes
                    .append(

                        ManagerFantasyFinish(

                            year:
                                finish.year,

                            place:
                                1
                        )
                    )

            } else if
                secondPlace == name {

                managerFantasyFinishes
                    .append(

                        ManagerFantasyFinish(

                            year:
                                finish.year,

                            place:
                                2
                        )
                    )

            } else if
                thirdPlace == name {

                managerFantasyFinishes
                    .append(

                        ManagerFantasyFinish(

                            year:
                                finish.year,

                            place:
                                3
                        )
                    )
            }
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

                    $0.year >
                    $1.year
                }


        // MARK: Build Profile

        return ManagerProfile(

            name:
                name,

            seasons:
                managerSeasons
                    .sorted {

                        $0.year >
                        $1.year
                    },

            earnings:
                managerEarnings,

            beerGameResults:
                beerGameResults,

            actualFantasyRecords:
                managerActualRecords,

            fantasyFinishes:
                managerFantasyFinishes
                    .sorted {

                        $0.year >
                        $1.year
                    }
        )
    }
}
