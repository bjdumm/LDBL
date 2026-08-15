//
//  PlayerRow.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct PlayerRow: View {

    @EnvironmentObject var draftStore: DraftStore

    let player: NFLPlayer

    @State private var showingConfirmation = false

    var body: some View {

        HStack {

            VStack(alignment: .leading) {

                Text(player.name)
                    .font(.headline)

                Text(
                    "\(player.position) • \(player.nflTeam)"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {

                showingConfirmation = true

            } label: {

                Text("Draft")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 5)
        .confirmationDialog(
            "Draft \(player.name)?",
            isPresented: $showingConfirmation
        ) {

            Button(
                "Draft \(player.name)"
            ) {

                draftStore.draft(player)
            }

            Button(
                "Cancel",
                role: .cancel
            ) { }

        } message: {

            if let manager =
                draftStore.currentManager {

                Text(
                    "\(manager.name) will select \(player.name)."
                )
            }
        }
    }
}
