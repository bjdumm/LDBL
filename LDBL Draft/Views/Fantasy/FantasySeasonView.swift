//
//  FantasySeasonView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct FantasySeasonView: View {

    let season: FantasySeasonDetails

    private var rankedPlayers:
        [FantasySeasonPlayer] {

        season.players.sorted {

            if $0.wins == $1.wins {
                return $0.losses < $1.losses
            }

            return $0.wins > $1.wins
        }
    }

    var body: some View {

        List {

            ForEach(
                Array(
                    rankedPlayers
                        .enumerated()
                ),
                id: \.element.id
            ) { index, player in

                NavigationLink {

                    FantasySeasonPlayerView(
                        player: player
                    )

                } label: {

                    HStack {

                        Text("#\(index + 1)")
                            .fontWeight(.bold)
                            .frame(width: 35)

                        Text(player.name)

                        Spacer()

                        Text(
                            "\(player.wins)-\(player.losses)"
                        )
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle(
            Text(
                verbatim:
                    String(season.year)
            )
        )
    }
}
