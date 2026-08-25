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

                    ContentUnavailableView(
                        "Unable to Load Managers",
                        systemImage:
                            "exclamationmark.triangle",
                        description:
                            Text(
                                leagueData.errorMessage
                            )
                    )

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
