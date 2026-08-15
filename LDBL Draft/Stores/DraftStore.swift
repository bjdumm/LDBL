//
//  DraftStore.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/14/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class DraftStore: ObservableObject {

    @Published var managers: [FantasyManager] = [
        FantasyManager(name: "Brennan"),
        FantasyManager(name: "Mike"),
        FantasyManager(name: "Dave"),
        FantasyManager(name: "Chris"),
        FantasyManager(name: "John"),
        FantasyManager(name: "Steve"),
        FantasyManager(name: "Matt"),
        FantasyManager(name: "Ryan"),
        FantasyManager(name: "Nick"),
        FantasyManager(name: "Tom")
    ]

    @Published var availablePlayers: [NFLPlayer] = [

        // QB
        NFLPlayer(name: "Josh Allen", position: "QB", nflTeam: "BUF"),
        NFLPlayer(name: "Lamar Jackson", position: "QB", nflTeam: "BAL"),
        NFLPlayer(name: "Jalen Hurts", position: "QB", nflTeam: "PHI"),
        NFLPlayer(name: "Joe Burrow", position: "QB", nflTeam: "CIN"),
        NFLPlayer(name: "Patrick Mahomes", position: "QB", nflTeam: "KC"),

        // RB
        NFLPlayer(name: "Bijan Robinson", position: "RB", nflTeam: "ATL"),
        NFLPlayer(name: "Saquon Barkley", position: "RB", nflTeam: "PHI"),
        NFLPlayer(name: "Jahmyr Gibbs", position: "RB", nflTeam: "DET"),
        NFLPlayer(name: "Jonathan Taylor", position: "RB", nflTeam: "IND"),
        NFLPlayer(name: "Christian McCaffrey", position: "RB", nflTeam: "SF"),

        // WR
        NFLPlayer(name: "Ja'Marr Chase", position: "WR", nflTeam: "CIN"),
        NFLPlayer(name: "Justin Jefferson", position: "WR", nflTeam: "MIN"),
        NFLPlayer(name: "CeeDee Lamb", position: "WR", nflTeam: "DAL"),
        NFLPlayer(name: "Amon-Ra St. Brown", position: "WR", nflTeam: "DET"),
        NFLPlayer(name: "Puka Nacua", position: "WR", nflTeam: "LAR"),

        // TE
        NFLPlayer(name: "Brock Bowers", position: "TE", nflTeam: "LV"),
        NFLPlayer(name: "Trey McBride", position: "TE", nflTeam: "ARI"),
        NFLPlayer(name: "George Kittle", position: "TE", nflTeam: "SF"),
        NFLPlayer(name: "Sam LaPorta", position: "TE", nflTeam: "DET"),
        NFLPlayer(name: "Mark Andrews", position: "TE", nflTeam: "BAL")
    ]

    @Published var draftPicks: [DraftPick] = []

    let totalRounds = 15

    var currentOverallPick: Int {
        draftPicks.count + 1
    }

    var currentRound: Int {
        ((currentOverallPick - 1) / managers.count) + 1
    }

    var currentPickInRound: Int {
        ((currentOverallPick - 1) % managers.count) + 1
    }

    var currentManager: FantasyManager? {

        guard !managers.isEmpty else {
            return nil
        }

        let indexInRound =
            (currentOverallPick - 1) % managers.count

        if currentRound % 2 == 1 {

            // Odd rounds:
            // 1 → 2 → 3 → ... → 10

            return managers[indexInRound]

        } else {

            // Even rounds:
            // 10 → 9 → 8 → ... → 1

            return managers[
                managers.count - 1 - indexInRound
            ]
        }
    }

    var draftComplete: Bool {
        draftPicks.count >= managers.count * totalRounds
    }

    func draft(_ player: NFLPlayer) {

        guard !draftComplete else {
            return
        }

        guard let manager = currentManager else {
            return
        }

        let pick = DraftPick(
            overallPick: currentOverallPick,
            round: currentRound,
            pickInRound: currentPickInRound,
            manager: manager,
            player: player
        )

        draftPicks.append(pick)

        availablePlayers.removeAll {
            $0.id == player.id
        }
    }

    func resetDraft() {
        draftPicks.removeAll()
    }
}
