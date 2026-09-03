import SwiftUI

struct ContentView: View {

    @StateObject private var leagueNews =
        LeagueNewsManager.shared

    var body: some View {
        ZStack {
            TabView {
                FantasyHomeView()
                    .tabItem {
                        Label(
                            "Fantasy",
                            systemImage: "football"
                        )
                    }

                BeerGamesHomeView()
                    .tabItem {
                        Label(
                            "Beer Games",
                            systemImage: "trophy"
                        )
                    }

                ManagersHomeView()
                    .tabItem {
                        Label(
                            "Managers",
                            systemImage: "person.3.fill"
                        )
                    }
            }

            if let news = leagueNews.currentNews {
                LeagueNewsPopupView(
                    news: news,
                    onDismiss: {
                        withAnimation(.spring()) {
                            leagueNews.dismissCurrent()
                        }
                    }
                )
                .transition(
                    .scale.combined(with: .opacity)
                )
                .zIndex(100)
            }
        }
        .animation(
            .spring(),
            value: leagueNews.currentNews?.id
        )
    }
}
