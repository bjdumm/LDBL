import SwiftUI

struct BeerGameAllTimeTopTenView: View {
    let eventName: String
    let scoreboard: [ScoreboardSeason]

    private var ranked: [BeerGamePerformance] {
        let all = BeerGamePerformanceRanking.performances(eventName: eventName, scoreboard: scoreboard)
        return Array(BeerGamePerformanceRanking.sorted(all, timed: BeerGamePerformanceRanking.isTimed(all)).prefix(10))
    }

    var body: some View {
        List {
            Section("All-Time Top 10") {
                if ranked.isEmpty {
                    Text("No historical results found for this event.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(ranked.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 12) {
                            Text("#\(index + 1)")
                                .fontWeight(.bold)
                                .frame(width: 34, alignment: .leading)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.player).fontWeight(.semibold)
                                Text(String(item.year)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(item.result).fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .navigationTitle(eventName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
