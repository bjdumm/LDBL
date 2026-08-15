//
//  BeerGamesRecordsView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct BeerGamesRecordsView: View {

    var body: some View {

        List {

            Section("All-Time Records") {

                Text("Most Championships")
                Text("Most Wins")
                Text("Best Single-Year Record")
            }
        }
        .navigationTitle("Records")
    }
}
