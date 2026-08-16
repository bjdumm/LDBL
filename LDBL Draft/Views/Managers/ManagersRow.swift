//
//  ManagersRow.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/16/26.
//

import SwiftUI

struct ManagerRow: View {

    let manager: ManagerProfile

    var body: some View {

        HStack(spacing: 14) {

            Image(
                systemName:
                    "person.crop.circle.fill"
            )
            .font(.largeTitle)
            .foregroundStyle(.secondary)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(manager.name)
                    .font(.headline)

                if manager.careerGames > 0 {

                    Text(
                        "\(manager.careerWins)-\(manager.careerLosses) career"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    if manager.beerGameSeasonsPlayed > 0 {

                        Text(
                            "\(manager.averageBeerGamePoints, specifier: "%.1f") avg Beer Game pts"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if manager.totalWinnings > 0 {

                Text(
                    manager.totalWinnings,
                    format:
                        .currency(
                            code: "USD"
                        )
                        .precision(
                            .fractionLength(0)
                        )
                )
                .font(.subheadline)
                .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}
