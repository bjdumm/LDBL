//
//  AccumulatedEarningsDetailView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct AccumulatedEarningsDetailView: View {

    let player: AccumulatedEarningsPlayer

    

    var body: some View {

        List {

            Section("Career") {

                moneyRow(
                    "Winnings",
                    player.totalWinnings
                )

                moneyRow(
                    "Fees",
                    player.totalFees
                )

                moneyRow(
                    "Return",
                    player.returnAmount
                )
            }

            Section("By Season") {
                
                ForEach(
                    player.yearlyWinnings
                ) { season in

                    HStack {

                        Text(
                            verbatim:
                                String(season.year)
                        )

                        Spacer()

                        if let amount =
                            season.amount {

                            Text(
                                amount,
                                format:
                                    .currency(
                                        code: "USD"
                                    )
                                    .precision(
                                        .fractionLength(0)
                                    )
                            )

                        } else {

                            Text("-")
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }
                }
            }
        }
        .navigationTitle(player.player)
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    private func moneyRow(
        _ title: String,
        _ amount: Double
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(
                amount,
                format:
                    .currency(
                        code: "USD"
                    )
                    .precision(
                        .fractionLength(0)
                    )
            )
            .fontWeight(.semibold)
        }
    }
}
