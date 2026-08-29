import SwiftUI

struct ManagersHomeView: View {

    @EnvironmentObject var leagueData:
        LeagueDataStore

    var body: some View {

        NavigationStack {

            Group {

                if leagueData.isLoading &&
                    leagueData.managers.isEmpty {

                    ProgressView(
                        "Loading Managers..."
                    )

                } else if
                    !leagueData.errorMessage.isEmpty &&
                    leagueData.managers.isEmpty {

                    VStack(spacing: 12) {

                        Image(
                            systemName: "chart.bar"
                        )
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                        Text(
                            "No Data Available"
                        )
                        .font(.headline)

                        Text(
                            "There is currently no player data to display."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .padding()

                } else {

                    List(
                        leagueData.managers
                    ) { manager in

                        NavigationLink {

                            ManagerDetailView(
                                manager: manager
                            )

                        } label: {

                            ManagerRow(
                                manager: manager
                            )
                        }
                    }
                }
            }
            .navigationTitle("Managers")
            .refreshable {

                await leagueData.refresh()
            }
        }
    }
}
