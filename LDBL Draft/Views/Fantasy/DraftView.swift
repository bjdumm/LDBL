import SwiftUI

struct DraftView: View {
    @EnvironmentObject var leagueData: LeagueDataStore

    var body: some View {
        Group {
            if leagueData.isLoading && leagueData.yearEndRosters.isEmpty {
                ProgressView("Loading Rosters...")
            } else if leagueData.yearEndRosters.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Year-End Rosters Available").font(.headline)
                    Text("Year-End Roster sheets will appear here automatically when they are added to the league spreadsheet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List(leagueData.yearEndRosters) { season in
                    NavigationLink {
                        YearEndRosterSeasonView(season: season)
                    } label: {
                        Label(String(season.year), systemImage: "calendar")
                    }
                }
            }
        }
        .navigationTitle("Draft")
        .refreshable { await leagueData.refresh() }
    }
}

private struct YearEndRosterSeasonView: View {
    let season: YearEndRosterSeason

    var body: some View {
        List(season.managers) { manager in
            NavigationLink {
                YearEndRosterManagerView(year: season.year, roster: manager)
            } label: {
                HStack {
                    Text(manager.manager)
                    Spacer()
                    Text("\(manager.draftPicks.count + manager.yearEndAdditions.count) players")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("\(season.year) Rosters")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct YearEndRosterManagerView: View {
    let year: Int
    let roster: YearEndRosterManager

    var body: some View {
        List {
            if !roster.draftPicks.isEmpty {
                Section("Draft Results") {
                    ForEach(roster.draftPicks) { pick in
                        HStack {
                            Text("Round \(pick.round)")
                                .foregroundStyle(.secondary)
                                .frame(width: 75, alignment: .leading)
                            Text(pick.player)
                        }
                    }
                }
            }

            if !roster.yearEndAdditions.isEmpty {
                Section("Year-End Roster") {
                    ForEach(Array(roster.yearEndAdditions.enumerated()), id: \.offset) { _, player in
                        Text(player)
                    }
                }
            }
        }
        .navigationTitle(roster.manager)
        .navigationBarTitleDisplayMode(.inline)
    }
}
