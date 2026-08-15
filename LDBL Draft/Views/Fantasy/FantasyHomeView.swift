//
//  FantasyHomeView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct FantasyHomeView: View {

    var body: some View {

        NavigationStack {

            List {


                NavigationLink {
                    FantasyHistoryView()
                } label: {
                    Label(
                        "League History",
                        systemImage: "clock.arrow.circlepath"
                    )
                }
            }
            .navigationTitle("Fantasy")
        }
    }
}


