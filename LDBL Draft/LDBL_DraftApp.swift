//
//  LDBL_DraftApp.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

@main
struct LDBL_DraftApp: App {

    @StateObject private var draftStore = DraftStore()

    var body: some Scene {

        WindowGroup {

            ContentView()
                .environmentObject(draftStore)
        }
    }
}
