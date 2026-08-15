//
//  NFLPlayer.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import Foundation

struct DraftPick: Identifiable {
    let id = UUID()
    let overallPick: Int
    let round: Int
    let pickInRound: Int
    let manager: FantasyManager
    let player: NFLPlayer
}
