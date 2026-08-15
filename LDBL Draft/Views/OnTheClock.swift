//
//  OnTheClock.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI

struct OnTheClockView: View {

    @EnvironmentObject var draftStore: DraftStore

    var body: some View {

        VStack(spacing: 8) {

            Text("ON THE CLOCK")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            if let manager = draftStore.currentManager {

                Text(manager.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            HStack {

                Text(
                    "Round \(draftStore.currentRound)"
                )

                Text("•")

                Text(
                    "Pick \(draftStore.currentOverallPick)"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color.blue.opacity(0.10)
        )
    }
}

#Preview {
    OnTheClockView()
        .environmentObject(DraftStore())
}
