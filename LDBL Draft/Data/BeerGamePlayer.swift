//
//  BeerGamePlayer.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import Foundation

struct BeerGamePlayer: Identifiable, Hashable {
    let id = UUID()

    let name: String

    let pong: Double
    let cornhole: Double
    let relays: Double
    let beerDie: Double
    let quarterPong: Double
    let speedball: Double
    let flipCup: Double
    let darts: Double
    let fourCorners: Double
    let showcaseEvent: Double

    var totalPoints: Double {
        pong
        + cornhole
        + relays
        + beerDie
        + quarterPong
        + speedball
        + flipCup
        + darts
        + fourCorners
        + showcaseEvent
    }
}
