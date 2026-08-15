//
//  TeamsView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct TeamsView: View {

    @EnvironmentObject var draftStore: DraftStore

    var body: some View {

        NavigationStack {

            List(draftStore.managers) { manager in

                NavigationLink {

                    ManagerRosterView(
                        manager: manager
                    )

                } label: {

                    VStack(alignment: .leading) {

                        Text(manager.name)
                            .font(.headline)

                        let count =
                            draftStore.draftPicks.filter {
                                $0.manager.id ==
                                manager.id
                            }.count

                        Text(
                            "\(count) players drafted"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Teams")
        }
    }
}

#Preview {
    TeamsView()
        .environmentObject(DraftStore())
}
