//
//  ManagerRosterView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct ManagerRosterView: View {

    @EnvironmentObject var draftStore: DraftStore

    let manager: FantasyManager

    var players: [DraftPick] {

        draftStore.draftPicks.filter {
            $0.manager.id == manager.id
        }
    }

    var body: some View {

        List {

            if players.isEmpty {

                Text("No players drafted yet.")
                    .foregroundStyle(.secondary)

            } else {

                ForEach(players) { pick in

                    HStack {

                        VStack(
                            alignment: .leading
                        ) {

                            Text(
                                pick.player.name
                            )
                            .fontWeight(.semibold)

                            Text(
                                "\(pick.player.position) • \(pick.player.nflTeam)"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }

                        Spacer()

                        Text(
                            "#\(pick.overallPick)"
                        )
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(manager.name)
    }
}
