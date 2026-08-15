//
//  DraftPick.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import SwiftUI
import Foundation

struct NFLPlayer: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let position: String
    let nflTeam: String
}
