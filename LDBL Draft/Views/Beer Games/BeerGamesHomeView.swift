//
//  BeerGamesHomeView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct BeerGamesHomeView: View {

    var body: some View {

        NavigationStack {

            List {

                NavigationLink {

                    ScoreboardAllView()

                } label: {

                    Label(
                        "Scoreboard",
                        systemImage:
                            "list.number"
                    )
                }


                NavigationLink {

                    GamesAndRulesView()

                } label: {

                    Label(
                        "Games & Rules",
                        systemImage:
                            "book.closed.fill"
                    )
                }


                NavigationLink {

                    BeerGameRecordHoldersView()

                } label: {

                    Label(
                        "Record Holders",
                        systemImage:
                            "trophy.fill"
                    )
                }
            }
            .navigationTitle(
                "Beer Games"
            )
        }
    }
}
