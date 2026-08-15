//
//  GameRulesModels.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct GamesRulesData {

    let eventDate: String

    let generalRules: [String]

    let games: [BeerGameRule]

    let showcaseNotes: [String]
}

struct BeerGameRule: Identifiable {

    var id: String { number }

    let number: String
    let title: String
    let description: String
    let drinkingRequirement: String
}
