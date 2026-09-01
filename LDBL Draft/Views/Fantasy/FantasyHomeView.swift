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

                Section("Results") {

                    NavigationLink {

                        SeasonDetailsView()

                    } label: {

                        Label(
                            "Season Details",
                            systemImage:
                                "calendar"
                        )
                    }


                    NavigationLink {

                        DraftView()

                    } label: {

                        Label(
                            "Draft",
                            systemImage:
                                "person.3.sequence.fill"
                        )
                    }


                    NavigationLink {

                        FantasyWinLossView()

                    } label: {

                        Label(
                            "Win-Loss Records",
                            systemImage:
                                "chart.bar.fill"
                        )
                    }
                }


                Section(
                    "League History"
                ) {

                    NavigationLink {

                        AccumulatedEarningsView()

                    } label: {

                        Label(
                            "Accumulated Earnings",
                            systemImage:
                                "dollarsign.circle.fill"
                        )
                    }
                }
            }
            .navigationTitle(
                "Fantasy"
            )
        }
    }
}
