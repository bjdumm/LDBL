//
//  BeerGameRecordHoldersParser.swift
//  LDBL Draft
//
//  Created by Brennan Dumm on 8/15/26.
//

import Foundation

struct BeerGameRecordHoldersParser {
    

        static func parse(
            rows: [[String]]
        ) -> BeerGameRecordHoldersData {

            let records =
                parseRecordSections(rows)

            let accumulatedPoints =
                parseAccumulatedPoints(rows)

            return BeerGameRecordHoldersData(
                eventRecords:
                    records.eventRecords,

                championships:
                    records.championships,

                accumulatedPoints:
                    accumulatedPoints
            )
        }
    
    
}

private extension BeerGameRecordHoldersParser {
    
    static func parseAccumulatedPoints(
        _ rows: [[String]]
    ) -> [AccumulatedBeerGamePoints] {
        
        guard let titleRowIndex =
                rows.firstIndex(
                    where: { row in
                        
                        row.contains {
                            clean($0) ==
                            "Accumulated Beer Game Points"
                        }
                    }
                )
        else {
            return []
        }
        
        let headerRowIndex =
        titleRowIndex + 1
        
        guard headerRowIndex < rows.count else {
            return []
        }
        
        let headers =
        rows[headerRowIndex]
        
        guard let playerColumn =
                index(
                    of: "Player",
                    in: headers
                )
        else {
            return []
        }
        
        guard let totalColumn =
                index(
                    of: "Total Pts",
                    in: headers
                )
        else {
            return []
        }
        
        // Find all columns whose header is a year.
        var yearColumns:
        [(year: Int, column: Int)] = []
        
        for (
            columnIndex,
            header
        ) in headers.enumerated() {
            
            if let year =
                Int(clean(header)),
               year >= 2000,
               year <= 2100 {
                
                yearColumns.append(
                    (
                        year: year,
                        column: columnIndex
                    )
                )
            }
        }
        
        var results:
        [AccumulatedBeerGamePoints] = []
        
        for row in rows.dropFirst(
            headerRowIndex + 1
        ) {
            
            let player =
            value(
                row,
                playerColumn
            )
            
            if player.isEmpty {
                break
            }
            
            var yearlyPoints:
            [Int: Double] = [:]
            
            for yearColumn in yearColumns {
                
                let rawValue =
                value(
                    row,
                    yearColumn.column
                )
                
                if let points =
                    Double(rawValue) {
                    
                    yearlyPoints[
                        yearColumn.year
                    ] = points
                }
            }
            
            let totalPoints =
            Double(
                value(
                    row,
                    totalColumn
                )
            ) ?? yearlyPoints.values.reduce(
                0,
                +
            )
            
            results.append(
                AccumulatedBeerGamePoints(
                    player: player,
                    yearlyPoints: yearlyPoints,
                    totalPoints: totalPoints
                )
            )
        }
        
        return results
    }
    
    static func parseRecordSections(
        _ rows: [[String]]
    ) -> (
        eventRecords: [BeerGameEventRecord],
        championships: [BeerGameChampionship]
    ) {
        
        guard let headerRowIndex =
                rows.firstIndex(
                    where: { row in
                        
                        row.contains {
                            clean($0) == "Event"
                        }
                        &&
                        row.contains {
                            clean($0) ==
                            "Beer Game Championships"
                        }
                    }
                )
        else {
            return ([], [])
        }
        
        let headers =
        rows[headerRowIndex]
        
        guard
            let eventColumn =
                index(
                    of: "Event",
                    in: headers
                ),
            
                let scoreColumn =
                index(
                    of: "Score",
                    in: headers
                ),
            
                let seasonColumn =
                index(
                    of: "Season",
                    in: headers
                ),
            
                let playerColumn =
                index(
                    of: "Nathlete",
                    in: headers
                ),
            
                let championshipsColumn =
                index(
                    of: "Beer Game Championships",
                    in: headers
                )
                
        else {
            return ([], [])
        }
        
        var eventRecords:
        [BeerGameEventRecord] = []
        
        var championships:
        [BeerGameChampionship] = []
        
        for row in rows.dropFirst(
            headerRowIndex + 1
        ) {
            
            let event =
            value(
                row,
                eventColumn
            )
            
            if !event.isEmpty {
                
                eventRecords.append(
                    BeerGameEventRecord(
                        event: event,
                        
                        score:
                            value(
                                row,
                                scoreColumn
                            ),
                        
                        season:
                            Int(
                                value(
                                    row,
                                    seasonColumn
                                )
                            ) ?? 0,
                        
                        player:
                            value(
                                row,
                                playerColumn
                            )
                    )
                )
            }
            
            
            let championshipPlayer =
            value(
                row,
                championshipsColumn
            )
            
            if !championshipPlayer.isEmpty {
                
                championships.append(
                    BeerGameChampionship(
                        player:
                            championshipPlayer,
                        
                        championships:
                            integer(
                                value(
                                    row,
                                    championshipsColumn + 1
                                )
                            )
                    )
                )
            }
        }
        
        return (
            eventRecords,
            championships
        )
    }
    
    
    
    static func index(
        of header: String,
        in row: [String]
    ) -> Int? {
        
        row.firstIndex {
            clean($0) == clean(header)
        }
    }
    
    
    static func clean(
        _ value: String
    ) -> String {
        
        value
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }
    
    
    static func value(
        _ row: [String],
        _ index: Int
    ) -> String {
        
        guard index >= 0,
              index < row.count else {
            return ""
        }
        
        return clean(row[index])
    }
    
    
    static func integer(
        _ value: String
    ) -> Int {
        
        if let number = Int(value) {
            return number
        }
        
        if let number = Double(value) {
            return Int(number)
        }
        
        return 0
    }
    
}
