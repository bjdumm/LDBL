import Foundation
import Combine

@MainActor
final class LeagueNewsManager: ObservableObject {

    static let shared = LeagueNewsManager()

    @Published private(set) var pendingNews: [LeagueNewsItem] = []

    var currentNews: LeagueNewsItem? {
        pendingNews.first
    }

    private let pendingKey = "ldbl.leagueNews.pending.v1"
    private let seenKey = "ldbl.leagueNews.seen.v1"
    private let snapshotKey = "ldbl.leagueNews.snapshot.v1"

    private var seenIDs = Set<String>()
    private var previousSnapshot: LeagueNewsSnapshot?

    private init() {
        loadStoredState()
    }

    // MARK: - Public Actions

    func dismissCurrent() {
        guard let current = pendingNews.first else {
            return
        }

        seenIDs.insert(current.id)
        pendingNews.removeFirst()

        savePendingNews()
        saveSeenIDs()
    }

    // MARK: - Process Fresh Scoreboard

    @discardableResult
    func processFreshScoreboard(
        _ scoreboard: [ScoreboardSeason]
    ) -> [LeagueNewsItem] {

        guard !scoreboard.isEmpty else {
            return []
        }

        let pendingIDsBefore =
            Set(pendingNews.map(\.id))

        let newSnapshot =
            makeSnapshot(from: scoreboard)

        // First fresh load establishes the historical baseline.
        //
        // Nothing already present in the spreadsheet should be
        // announced as new on a fresh install.
        guard let oldSnapshot = previousSnapshot else {

            previousSnapshot = newSnapshot
            saveSnapshot(newSnapshot)

            print(
                "📰 League News baseline established."
            )

            return []
        }

        detectNewRecords(
            old: oldSnapshot,
            new: newSnapshot
        )

        detectCompletedEventWinners(
            old: oldSnapshot,
            new: newSnapshot
        )

        detectCompletedBeerGamesChampions(
            old: oldSnapshot,
            new: newSnapshot
        )

        previousSnapshot = newSnapshot
        saveSnapshot(newSnapshot)

        return pendingNews.filter {
            !pendingIDsBefore.contains($0.id)
        }
    }

    // MARK: - Record Detection

    private func detectNewRecords(
        old: LeagueNewsSnapshot,
        new: LeagueNewsSnapshot
    ) {

        for (eventKey, newRecord) in new.records {

            guard let oldRecord =
                old.records[eventKey]
            else {
                // A newly appearing historical event should
                // not generate an announcement.
                continue
            }

            let improved: Bool

            if newRecord.timed {

                improved =
                    newRecord.sortValue <
                    oldRecord.sortValue

            } else {

                improved =
                    newRecord.sortValue >
                    oldRecord.sortValue
            }

            guard improved else {
                continue
            }

            let id = [
                "beer-record",
                eventKey,
                newRecord.player,
                String(newRecord.year),
                newRecord.result
            ]
            .joined(separator: "|")

            enqueue(
                LeagueNewsItem(
                    id: id,
                    type: .beerGameRecord,
                    title: "🏆 NEW BEER GAMES RECORD!",
                    message:
                        "\(newRecord.player) has just set a new \(newRecord.eventName) record with \(newRecord.result)!!!",
                    player: newRecord.player,
                    event: newRecord.eventName,
                    result: newRecord.result,
                    year: newRecord.year
                )
            )
        }
    }

    // MARK: - Event Winner Detection

    private func detectCompletedEventWinners(
        old: LeagueNewsSnapshot,
        new: LeagueNewsSnapshot
    ) {

        for (key, winner) in new.eventWinners {

            // The year must have existed in the previous
            // scoreboard snapshot.
            //
            // This prevents historical seasons that suddenly
            // appear during a full reload from generating alerts.
            guard old.seasonYears.contains(winner.year) else {

                print(
                    "📰 Ignoring historical event winner: \(winner.year) \(winner.eventName)"
                )

                continue
            }

            if let oldWinner =
                old.eventWinners[key],
               oldWinner == winner {

                continue
            }

            let id = [
                "beer-event-winner",
                String(winner.year),
                winner.eventKey,
                winner.player,
                winner.result
            ]
            .joined(separator: "|")

            enqueue(
                LeagueNewsItem(
                    id: id,
                    type: .beerGameEventWinner,
                    title: "🍺 \(winner.eventName) WINNER!",
                    message:
                        "\(winner.player) has won the \(winner.eventName) event!",
                    player: winner.player,
                    event: winner.eventName,
                    result: winner.result,
                    year: winner.year
                )
            )
        }
    }

    // MARK: - Champion Detection

    private func detectCompletedBeerGamesChampions(
        old: LeagueNewsSnapshot,
        new: LeagueNewsSnapshot
    ) {

        for (yearKey, champion) in new.champions {

            // --------------------------------------------------
            // Historical-season protection
            // --------------------------------------------------
            //
            // 2026 existed previously but was incomplete:
            //     -> champion may be announced when completed
            //
            // 2016 was not present in previous snapshot and
            // suddenly appears during a reload:
            //     -> do NOT announce
            //
            guard old.seasonYears.contains(
                champion.year
            ) else {

                print(
                    "📰 Ignoring historical champion: \(champion.year) \(champion.player)"
                )

                continue
            }

            // Exact same champion already known.
            if let oldChampion =
                old.champions[yearKey],
               oldChampion == champion {

                continue
            }

            let id = [
                "beer-games-champion",
                String(champion.year),
                champion.player,
                String(champion.totalPoints)
            ]
            .joined(separator: "|")

            enqueue(
                LeagueNewsItem(
                    id: id,
                    type: .beerGamesChampion,
                    title: "👑 BEER GAMES CHAMPION!",
                    message:
                        "\(champion.player) has won the \(champion.year) Beer Games with \(champion.totalPoints) points!",
                    player: champion.player,
                    event: nil,
                    result:
                        "\(champion.totalPoints) points",
                    year: champion.year
                )
            )

            print(
                "👑 New Beer Games champion: \(champion.player) \(champion.year)"
            )
        }
    }

    // MARK: - Build Snapshot

    private func makeSnapshot(
        from scoreboard: [ScoreboardSeason]
    ) -> LeagueNewsSnapshot {

        LeagueNewsSnapshot(
            records:
                makeRecordSnapshots(
                    from: scoreboard
                ),

            eventWinners:
                makeEventWinnerSnapshots(
                    from: scoreboard
                ),

            champions:
                makeChampionSnapshots(
                    from: scoreboard
                ),

            seasonYears:
                Set(scoreboard.map(\.year))
        )
    }

    // MARK: - Record Snapshots

    private func makeRecordSnapshots(
        from scoreboard: [ScoreboardSeason]
    ) -> [String: LeagueNewsRecordSnapshot] {

        var result:
            [String: LeagueNewsRecordSnapshot] = [:]

        var eventNames:
            [String: String] = [:]

        // Collect every unique event represented
        // anywhere in the scoreboard.
        for season in scoreboard {

            for entry in season.entries {

                for event in entry.events {

                    let key =
                        BeerGamePerformanceRanking
                            .eventKey(
                                event.event
                            )

                    guard !key.isEmpty else {
                        continue
                    }

                    eventNames[key] =
                        event.event
                }
            }
        }

        // Use your existing BeerGamePerformanceRanking
        // API to determine the all-time record.
        for (eventKey, eventName) in eventNames {

            let performances =
                BeerGamePerformanceRanking
                    .performances(
                        eventName: eventName,
                        scoreboard: scoreboard
                    )

            guard !performances.isEmpty else {
                continue
            }

            let timed =
                BeerGamePerformanceRanking
                    .isTimed(
                        performances
                    )

            let ranked =
                BeerGamePerformanceRanking
                    .sorted(
                        performances,
                        timed: timed
                    )

            guard let best = ranked.first,
                  let value = best.sortValue
            else {
                continue
            }

            result[eventKey] =
                LeagueNewsRecordSnapshot(
                    eventKey: eventKey,
                    eventName: best.event,
                    player: best.player,
                    year: best.year,
                    result: best.result,
                    sortValue: value,
                    timed: timed
                )
        }

        return result
    }

    // MARK: - Event Winner Snapshots

    private func makeEventWinnerSnapshots(
        from scoreboard: [ScoreboardSeason]
    ) -> [String: LeagueNewsWinnerSnapshot] {

        var result:
            [String: LeagueNewsWinnerSnapshot] = [:]

        for season in scoreboard {

            let eventNames =
                uniqueEventNames(
                    in: season
                )

            for eventName in eventNames {

                guard isEventComplete(
                    eventName: eventName,
                    season: season
                ) else {
                    continue
                }

                let performances =
                    BeerGamePerformanceRanking
                        .performances(
                            eventName: eventName,
                            scoreboard: [season]
                        )

                guard !performances.isEmpty else {
                    continue
                }

                // Award points determine the official winner.
                guard let highestPoints =
                    performances
                        .map(\.awardPoints)
                        .max()
                else {
                    continue
                }

                let leaders =
                    performances.filter {
                        $0.awardPoints ==
                        highestPoints
                    }

                // Never announce an ambiguous tie.
                guard leaders.count == 1,
                      let winner = leaders.first
                else {
                    continue
                }

                let eventKey =
                    BeerGamePerformanceRanking
                        .eventKey(
                            eventName
                        )

                let key =
                    "\(season.year)|\(eventKey)"

                result[key] =
                    LeagueNewsWinnerSnapshot(
                        year: season.year,
                        eventKey: eventKey,
                        eventName: eventName,
                        player: winner.player,
                        result: winner.result
                    )
            }
        }

        return result
    }

    // MARK: - Champion Snapshots

    private func makeChampionSnapshots(
        from scoreboard: [ScoreboardSeason]
    ) -> [String: LeagueNewsChampionSnapshot] {

        var result:
            [String: LeagueNewsChampionSnapshot] = [:]

        for season in scoreboard {

            guard isSeasonComplete(
                season
            ) else {
                continue
            }

            guard !season.entries.isEmpty else {
                continue
            }

            guard let highestTotal =
                season.entries
                    .map(\.totalPoints)
                    .max()
            else {
                continue
            }

            let leaders =
                season.entries.filter {
                    $0.totalPoints ==
                    highestTotal
                }

            // Don't crown someone while totals are tied.
            guard leaders.count == 1,
                  let champion = leaders.first
            else {
                continue
            }

            let normalizedPlayer =
                ManagerNameNormalizer
                    .normalize(
                        champion.player
                    )

            let key =
                String(season.year)

            result[key] =
                LeagueNewsChampionSnapshot(
                    year: season.year,
                    player: normalizedPlayer,
                    totalPoints:
                        champion.totalPoints
                )
        }

        return result
    }

    // MARK: - Season Completion

    private func isSeasonComplete(
        _ season: ScoreboardSeason
    ) -> Bool {

        let eventNames =
            uniqueEventNames(
                in: season
            )

        guard !eventNames.isEmpty else {
            return false
        }

        return eventNames.allSatisfy {
            isEventComplete(
                eventName: $0,
                season: season
            )
        }
    }

    // MARK: - Event Completion

    private func isEventComplete(
        eventName: String,
        season: ScoreboardSeason
    ) -> Bool {

        guard !season.entries.isEmpty else {
            return false
        }

        for entry in season.entries {

            guard let event =
                entry.events.first(
                    where: {
                        BeerGamePerformanceRanking
                            .eventKey(
                                $0.event
                            )
                        ==
                        BeerGamePerformanceRanking
                            .eventKey(
                                eventName
                            )
                    }
                )
            else {
                return false
            }

            let value =
                event.result
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )

            // Blank result means event isn't done yet.
            guard !value.isEmpty else {
                return false
            }

            // "-" means manager intentionally didn't compete,
            // which counts as completed.
            if value == "-" {
                continue
            }

            // DNF also counts as a completed result.
            //
            // Actual participants need Award Points entered
            // before the event is considered complete.
            guard event.pointsEntered else {
                return false
            }
        }

        return true
    }

    // MARK: - Event Names

    private func uniqueEventNames(
        in season: ScoreboardSeason
    ) -> [String] {

        var namesByKey:
            [String: String] = [:]

        for entry in season.entries {

            for event in entry.events {

                let key =
                    BeerGamePerformanceRanking
                        .eventKey(
                            event.event
                        )

                guard !key.isEmpty else {
                    continue
                }

                namesByKey[key] =
                    event.event
            }
        }

        return namesByKey
            .values
            .sorted()
    }

    // MARK: - Queue

    private func enqueue(
        _ item: LeagueNewsItem
    ) {

        guard
            !seenIDs.contains(item.id),
            !pendingNews.contains(
                where: {
                    $0.id == item.id
                }
            )
        else {
            return
        }

        pendingNews.append(item)

        savePendingNews()
    }

    // MARK: - Load State

    private func loadStoredState() {

        let defaults =
            UserDefaults.standard

        let decoder =
            JSONDecoder()

        if let data =
            defaults.data(
                forKey: pendingKey
            ),
           let stored =
            try? decoder.decode(
                [LeagueNewsItem].self,
                from: data
            ) {

            pendingNews = stored
        }

        if let data =
            defaults.data(
                forKey: seenKey
            ),
           let stored =
            try? decoder.decode(
                [String].self,
                from: data
            ) {

            seenIDs =
                Set(stored)
        }

        if let data =
            defaults.data(
                forKey: snapshotKey
            ),
           let stored =
            try? decoder.decode(
                LeagueNewsSnapshot.self,
                from: data
            ) {

            previousSnapshot = stored
        }
    }

    // MARK: - Save Pending

    private func savePendingNews() {

        guard let data =
            try? JSONEncoder()
                .encode(
                    pendingNews
                )
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: pendingKey
        )
    }

    // MARK: - Save Seen

    private func saveSeenIDs() {

        guard let data =
            try? JSONEncoder()
                .encode(
                    Array(seenIDs)
                )
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: seenKey
        )
    }

    // MARK: - Save Snapshot

    private func saveSnapshot(
        _ snapshot: LeagueNewsSnapshot
    ) {

        guard let data =
            try? JSONEncoder()
                .encode(
                    snapshot
                )
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: snapshotKey
        )
    }
}
