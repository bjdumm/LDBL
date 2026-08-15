//
//  DraftView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//
import SwiftUI

struct DraftView: View {

    @EnvironmentObject var draftStore: DraftStore

    @State private var selectedPosition = "ALL"
    @State private var searchText = ""

    let positions = [
        "ALL",
        "QB",
        "RB",
        "WR",
        "TE"
    ]

    var filteredPlayers: [NFLPlayer] {

        draftStore.availablePlayers.filter { player in

            let matchesPosition =
                selectedPosition == "ALL" ||
                player.position == selectedPosition

            let matchesSearch =
                searchText.isEmpty ||
                player.name.localizedCaseInsensitiveContains(searchText)

            return matchesPosition && matchesSearch
        }
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                OnTheClockView()

                Divider()

                positionPicker

                playerList
            }
            .navigationTitle("Fantasy Draft")
            .searchable(
                text: $searchText,
                prompt: "Search NFL players"
            )
        }
    }

    private var positionPicker: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack {

                ForEach(positions, id: \.self) { position in

                    Button {

                        selectedPosition = position

                    } label: {

                        Text(position)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedPosition == position
                                ? Color.blue
                                : Color.gray.opacity(0.15)
                            )
                            .foregroundStyle(
                                selectedPosition == position
                                ? .white
                                : .primary
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
    }

    private var playerList: some View {

        List(filteredPlayers) { player in

            PlayerRow(player: player)
        }
        .listStyle(.plain)
    }
}

