//
//  ContentView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct ContentView: View {

    var body: some View {

        TabView {

            DraftView()
                .tabItem {
                    Label(
                        "Draft",
                        systemImage: "football"
                    )
                }

            DraftBoardView()
                .tabItem {
                    Label(
                        "Board",
                        systemImage: "list.number"
                    )
                }

            TeamsView()
                .tabItem {
                    Label(
                        "Teams",
                        systemImage: "person.3"
                    )
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DraftStore())
}
