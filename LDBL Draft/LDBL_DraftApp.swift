//
//  LDBL_DraftApp.swift
//  LDBL Draft
//
//  Always refresh fresh league data whenever the app becomes active.
//

import SwiftUI

@main
struct LDBLApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    @Environment(\.scenePhase)
    private var scenePhase

    @StateObject private var leagueData =
        LeagueDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(leagueData)

                // Initial launch:
                // show cache immediately, then fetch Google.
                .task {
                    await leagueData.loadIfNeeded()
                }

                // Push notification / remote-change signal:
                // immediately request fresh Google data.
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: .ldblRemoteDataChanged
                    )
                ) { _ in

                    Task {
                        await leagueData.forceRefresh()
                    }
                }

                // Every single time the app returns to the foreground,
                // force a fresh Google Sheet fetch.
                .onChange(of: scenePhase) { newPhase in

                    guard newPhase == .active else {
                        return
                    }

                    Task {
                        await leagueData
                            .refreshWhenAppBecomesActive()
                    }
                }
        }
    }
}
