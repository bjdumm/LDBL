//
//  DraftBoardView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct DraftBoardView: View {

    @EnvironmentObject var draftStore: DraftStore

    var body: some View {

        NavigationStack {

            Group {

                if draftStore.draftPicks.isEmpty {

                    ContentUnavailableView(
                        "No Picks Yet",
                        systemImage: "football",
                        description: Text(
                            "Draft selections will appear here."
                        )
                    )

                } else {

                    List(
                        draftStore.draftPicks
                    ) { pick in

                        HStack {

                            Text(
                                "\(pick.overallPick)"
                            )
                            .font(.headline)
                            .frame(width: 35)

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

                            VStack(
                                alignment: .trailing
                            ) {

                                Text(
                                    pick.manager.name
                                )

                                Text(
                                    "Round \(pick.round)"
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Draft Board")
        }
    }
}

#Preview {
    DraftBoardView()
        .environmentObject(DraftStore())
}
