import Foundation

struct BeerGamePerformance: Identifiable {
    var id: String { "\(event)-\(year)-\(player)-\(result)" }

    let event: String
    let player: String
    let year: Int
    let result: String
    let awardPoints: Int
    let sortValue: Double?
}

enum BeerGamePerformanceRanking {

    // MARK: - Build Performances

    static func performances(
        eventName: String,
        scoreboard: [ScoreboardSeason]
    ) -> [BeerGamePerformance] {

        // Overall Points comes from each season total rather than an
        // individual event column.
        if eventKey(eventName) == "overallpoints" {
            return scoreboard.flatMap { season in
                season.entries.compactMap { entry in
                    guard entry.totalPoints > 0 else {
                        return nil
                    }

                    return BeerGamePerformance(
                        event: eventName,
                        player: ManagerNameNormalizer.normalize(entry.player),
                        year: season.year,
                        result: String(entry.totalPoints),
                        awardPoints: entry.totalPoints,
                        sortValue: Double(entry.totalPoints)
                    )
                }
            }
        }

        return scoreboard.flatMap { season in
            season.entries.compactMap { entry in
                guard let event = entry.events.first(where: {
                    eventsMatch($0.event, eventName)
                }) else {
                    return nil
                }

                let result = event.result
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard !result.isEmpty,
                      result != "-"
                else {
                    return nil
                }

                return BeerGamePerformance(
                    event: event.event,
                    player: ManagerNameNormalizer.normalize(entry.player),
                    year: season.year,
                    result: result,
                    awardPoints: event.points,
                    sortValue: comparableValue(result)
                )
            }
        }
    }


    // MARK: - Result Type

    static func isTimed(
        _ performances: [BeerGamePerformance]
    ) -> Bool {

        let usable = performances
            .map(\.result)
            .filter { !$0.isEmpty }

        guard !usable.isEmpty else {
            return false
        }

        let timedCount = usable.filter {
            looksTimed($0)
        }.count

        return timedCount * 2 >= usable.count
    }


    // MARK: - Sort

    static func sorted(
        _ performances: [BeerGamePerformance],
        timed: Bool
    ) -> [BeerGamePerformance] {

        // For timed games, invalid/non-finish values (DNF, blank-like
        // placeholders, zero) must never become an artificially great time.
        // For numeric/points games, only results with a numeric value are
        // eligible for an all-time numerical leaderboard.
        let valid = performances.filter { item in
            guard let value = item.sortValue else {
                return false
            }

            if timed {
                return value > 0
            }

            return true
        }

        return valid.sorted { lhs, rhs in
            guard let lhsValue = lhs.sortValue,
                  let rhsValue = rhs.sortValue
            else {
                return lhs.player.localizedCaseInsensitiveCompare(rhs.player)
                    == .orderedAscending
            }

            if lhsValue != rhsValue {
                return timed
                    ? lhsValue < rhsValue
                    : lhsValue > rhsValue
            }

            if lhs.year != rhs.year {
                return lhs.year < rhs.year
            }

            return lhs.player.localizedCaseInsensitiveCompare(rhs.player)
                == .orderedAscending
        }
    }


    // MARK: - Time Detection / Parsing

    static func looksTimed(
        _ result: String
    ) -> Bool {
        result.contains(":") ||
        result.lowercased().contains("sec") ||
        result.lowercased().contains("min")
    }


    static func comparableValue(
        _ raw: String
    ) -> Double? {

        var text = raw
            .lowercased()
            .replacingOccurrences(of: "seconds", with: "")
            .replacingOccurrences(of: "second", with: "")
            .replacingOccurrences(of: "secs", with: "")
            .replacingOccurrences(of: "sec", with: "")
            .replacingOccurrences(of: "minutes", with: "")
            .replacingOccurrences(of: "minute", with: "")
            .replacingOccurrences(of: "mins", with: "")
            .replacingOccurrences(of: "min", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            return nil
        }

        // Historical Scoreboard ALL data uses several time formats:
        //   0:25:42  -> 25.42 sec
        //   1:06.65  -> 66.65 sec
        //   38.06    -> 38.06 sec
        //   57:40    -> 57.40 sec (legacy seconds:hundredths format)
        //
        // Supporting all of them keeps the leaderboard correct across all
        // seasons without rewriting the spreadsheet.
        if text.contains(":") {
            let rawParts = text.split(separator: ":", omittingEmptySubsequences: false)
            let parts = rawParts.compactMap {
                Double(String($0))
            }

            guard parts.count == rawParts.count else {
                return nil
            }

            if parts.count == 3 {
                return parts[0] * 60 +
                    parts[1] +
                    parts[2] / 100
            }

            if parts.count == 2 {
                let first = parts[0]
                let second = parts[1]

                // If the second component already contains a decimal,
                // this is minutes:seconds.decimal.
                if rawParts[1].contains(".") {
                    return first * 60 + second
                }

                // Older rows sometimes omit the leading zero and store a
                // sub-minute time as seconds:hundredths (e.g. 57:40).
                if first >= 10 {
                    return first + second / 100
                }

                // Otherwise treat it as minutes:seconds.
                return first * 60 + second
            }
        }

        text = text.replacingOccurrences(of: ",", with: "")
        return Double(text)
    }


    // MARK: - Event Name Matching

    private static func eventsMatch(
        _ lhs: String,
        _ rhs: String
    ) -> Bool {
        eventKey(lhs) == eventKey(rhs)
    }


    static func eventKey(
        _ value: String
    ) -> String {
        let key = value
            .lowercased()
            .filter {
                $0.isLetter || $0.isNumber
            }

        switch key {
        case "flipcupgame":
            return "flipcup"
        case "4corners":
            return "fourcorners"
        case "showcaseevent":
            return "showcase"
        default:
            return key
        }
    }
}
