//
//  LDBL_DraftApp.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

@main
struct LDBLApp: App {

    @StateObject private var leagueData =
        LeagueDataStore()

    var body: some Scene {

        WindowGroup {

            ContentView()
                .environmentObject(
                    leagueData
                )
                .task {

                    await leagueData
                        .loadIfNeeded()
                }
        }
    }
}
