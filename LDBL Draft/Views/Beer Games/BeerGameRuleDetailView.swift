//
//  BeerGameRuleDetailView.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import SwiftUI

struct BeerGameRuleDetailView: View {

    let game: BeerGameRule

    var body: some View {

        List {

            Section("Description") {

                Text(game.description)
            }

            if !game
                .drinkingRequirement
                .isEmpty {

                Section(
                    "Drinking Requirement"
                ) {

                    Text(
                        game.drinkingRequirement
                    )
                }
            }
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}
