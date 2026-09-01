import SwiftUI

struct ManagerBeerGamePersonalRecordsView: View {
    let managerName: String
    let scoreboard: [ScoreboardSeason]

    private var records: [PersonalEventRecord] {
        let eventNames = Set(
            scoreboard
                .flatMap { $0.entries }
                .flatMap { $0.events }
                .map { $0.event }
        )

        return eventNames.compactMap { eventName in
            let all = BeerGamePerformanceRanking
                .performances(
                    eventName: eventName,
                    scoreboard: scoreboard
                )
                .filter {
                    ManagerNameNormalizer.normalize($0.player) ==
                    ManagerNameNormalizer.normalize(managerName)
                }

            guard !all.isEmpty else {
                return nil
            }

            let timed =
                BeerGamePerformanceRanking
                    .isTimed(all)

            let ranked =
                BeerGamePerformanceRanking
                    .sorted(
                        all,
                        timed: timed
                    )

            guard let best = ranked.first else {
                return nil
            }

            let worst: BeerGamePerformance

            // Showcase is a timed event. Todd's 2021 DNF is intentionally
            // treated as worse than every completed Showcase time so it is
            // preserved as his personal worst instead of being discarded by
            // the numeric leaderboard sorter.
            let showcaseDNF = all
                .filter { item in
                    isDNF(item.result)
                }
                .sorted { lhs, rhs in
                    lhs.year < rhs.year
                }
                .first

            if isShowcase(eventName),
               let dnf = showcaseDNF {

                worst = dnf

            } else if let last = ranked.last {

                worst = last

            } else {

                return nil
            }

            return PersonalEventRecord(
                event: eventName,
                best: best,
                worst: worst
            )
        }
        .sorted {
            $0.event.localizedCaseInsensitiveCompare(
                $1.event
            ) == .orderedAscending
        }
    }

    var body: some View {
        List(records) { record in
            Section(record.event) {
                resultRow(
                    "Best",
                    record.best
                )

                resultRow(
                    "Worst",
                    record.worst
                )
            }
        }
        .navigationTitle(
            "Personal Records"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    private func resultRow(
        _ label: String,
        _ item: BeerGamePerformance
    ) -> some View {
        HStack {
            Text(label)

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 2
            ) {
                Text(item.result)
                    .fontWeight(.semibold)

                Text(String(item.year))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func isShowcase(
        _ eventName: String
    ) -> Bool {
        let canonical = eventName
            .lowercased()
            .filter {
                $0.isLetter || $0.isNumber
            }

        return canonical == "showcase" ||
            canonical == "showcaseevent"
    }

    private func isDNF(
        _ result: String
    ) -> Bool {
        result
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .caseInsensitiveCompare(
                "DNF"
            ) == .orderedSame
    }
}

private struct PersonalEventRecord: Identifiable {
    var id: String { event }
    let event: String
    let best: BeerGamePerformance
    let worst: BeerGamePerformance
}
