//
//  AccumulatedEarningsModel.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct AccumulatedEarningsPlayer: Identifiable {

    var id: String { player }

    let player: String

    let yearlyWinnings: [YearlyEarnings]

    let totalWinnings: Double
    let totalFees: Double

    var returnAmount: Double {
        totalWinnings - totalFees
    }
}


struct YearlyEarnings: Identifiable {

    var id: Int { year }

    let year: Int
    let amount: Double?
}
