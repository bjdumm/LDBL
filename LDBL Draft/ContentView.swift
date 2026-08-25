import SwiftUI

struct ContentView: View {

    var body: some View {

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
    }
}


