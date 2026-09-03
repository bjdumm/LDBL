//
//  LeagueDataStore.swift
//  LDBL Draft
//
//  Fresh-data-first version.
//
//  Cached data is still shown immediately at launch,
//  but Google is always queried whenever the app
//  launches or becomes active.
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


    // MARK: - Internal State

    private var hasLoaded = false
    private var hasCompletedInitialLoad = false

    /*
     If multiple things ask for a refresh at almost
     the same time — for example:

     - app enters foreground
     - push notification arrives
     - view appears

     — we don't want to fire several Google requests.

     If a refresh is already happening, we remember
     that another fresh request was requested and run
     one more immediately afterward.
    */

    private var refreshRequestedWhileRefreshing = false


    // MARK: - Initial App Load

    func loadIfNeeded() async {

        guard !hasLoaded else {
            return
        }

        hasLoaded = true

        var loadedCache = false


        // MARK: Load Cache

        /*
         The cache exists ONLY to make the app
         appear immediately.

         Cached data is never considered authoritative
         for league-news detection.
        */

        do {

            if let cached =
                try await LeagueDataCache
                    .shared
                    .load() {

                let payload =
                    try SpreadsheetService
                        .shared
                        .parseLeagueData(
                            from: cached.sheets
                        )

                apply(
                    payload,
                    processLeagueNews: false
                )

                lastUpdated =
                    cached.lastUpdated

                loadedCache = true

                print(
                    "📦 Loaded league data from local cache."
                )
            }

        } catch {

            print(
                "⚠️ Unable to load league cache:",
                error.localizedDescription
            )
        }


        if !loadedCache {
            isLoading = true
        }


        // MARK: Always Get Fresh Google Data

        /*
         Every launch ALWAYS requests Google.

         This is intentional.

         We do not care how young the cache is.
        */

        await performGoogleRefresh(
            showLoading: !loadedCache
        )


        hasCompletedInitialLoad = true
    }


    // MARK: - App Became Active

    /*
     This is the important method for your use case.

     Any time the manager returns to LDBL from:

     - Home Screen
     - another app
     - lock screen
     - notification
     - Control Center interruption

     we immediately fetch Google again.
    */

    func refreshWhenAppBecomesActive() async {

        /*
         During the very first launch,
         loadIfNeeded() is already doing the
         authoritative Google fetch.

         Avoid creating a duplicate request
         during that initial startup.
        */

        guard hasCompletedInitialLoad else {
            return
        }

        print(
            "🔄 App became active — forcing fresh Google Sheet fetch."
        )

        await forceRefresh()
    }


    // MARK: - Public Manual Refresh

    /*
     Existing views can continue calling:

         await leagueData.refresh()

     This ALWAYS requests Google.
    */

    func refresh() async {

        await forceRefresh()
    }


    // MARK: - Forced Refresh

    func forceRefresh() async {
        // SwiftUI .refreshable waits for this call. If another refresh is
        // already running, wait for it rather than returning immediately.
        while isRefreshing {
            try? await Task.sleep(for: .milliseconds(100))
        }

        await performGoogleRefresh(showLoading: false)
    }

    // MARK: - Google Refresh

    private func performGoogleRefresh(
        showLoading: Bool
    ) async {

        guard !isRefreshing else { return }


        isRefreshing = true

        errorMessage = ""


        if showLoading {
            isLoading = true
        }


        print(
            "🌐 Fetching fresh league data from Google..."
        )


        defer {

            isRefreshing = false

            isLoading = false
        }


        do {

            let freshData =
                try await SpreadsheetService
                    .shared
                    .fetchLeagueData()


            // MARK: Update UI Immediately

            /*
             This publishes the newly fetched
             scoreboard/fantasy data to every view.

             League News is processed from THIS
             fresh scoreboard.
            */

            apply(
                freshData.payload,
                processLeagueNews: true
            )


            lastUpdated =
                Date()


            print(
                "✅ Fresh Google data applied to app."
            )


            // MARK: Save Fresh Data To Cache

            do {

                try await LeagueDataCache
                    .shared
                    .save(
                        sheets:
                            freshData.rawSheets
                    )

                print(
                    "💾 Fresh league data saved to local cache."
                )

            } catch {

                /*
                 Cache failure should never stop
                 the freshly loaded UI data.
                */

                print(
                    "⚠️ Unable to save league cache:",
                    error.localizedDescription
                )
            }


            print(
                "✅ League data refresh complete."
            )


        } catch {

            /*
             IMPORTANT:

             Never erase the existing UI data
             because of a network failure.

             Cached / previously fetched data
             remains visible.
            */

            errorMessage =
                error.localizedDescription


            print(
                "❌ League refresh failed:",
                error.localizedDescription
            )
        }
    }


    // MARK: - Apply Loaded Data

    private func apply(
        _ data: LeagueDataPayload,
        processLeagueNews: Bool
    ) {

        // MARK: Fantasy

        seasonDetails =
            data.seasonDetails


        fantasyWinLoss =
            data.fantasyWinLoss


        accumulatedEarnings =
            data.accumulatedEarnings


        yearEndRosters =
            data.yearEndRosters


        // MARK: Beer Games

        scoreboard =
            data.scoreboard


        /*
         Only fresh Google data reaches this with
         processLeagueNews == true.

         Cached data cannot accidentally generate
         old winner/champion announcements.
        */

        if processLeagueNews {

            LeagueNewsManager
                .shared
                .processFreshScoreboard(
                    data.scoreboard
                )
        }


        beerGameRecordHolders =
            data.beerGameRecordHolders


        gamesAndRules =
            data.gamesAndRules


        // MARK: Managers

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
