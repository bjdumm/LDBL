//
//  BeerGameRecordNotificationManager.swift
//  LDBL Draft
//

import Foundation
import UserNotifications

final class BeerGameRecordNotificationManager {

    static let shared =
        BeerGameRecordNotificationManager()

    private init() {}


    // MARK: - Request Permission

    func requestPermission() {

        UNUserNotificationCenter
            .current()
            .requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge
                ]
            ) { granted, error in

                if let error {
                    print(
                        "Notification permission error:",
                        error.localizedDescription
                    )
                    return
                }

                print(
                    "Notification permission granted:",
                    granted
                )
            }
    }


    // MARK: - Compare Scoreboards

    func checkForNewRecords(
        oldScoreboard: [ScoreboardSeason],
        newScoreboard: [ScoreboardSeason]
    ) {

        /*
         We intentionally don't send
         notifications if there was no
         previous scoreboard.

         Otherwise a brand-new install
         could announce every historical
         league record.
        */

        guard !oldScoreboard.isEmpty else {
            return
        }


        let eventNames =
            allEventNames(
                in: newScoreboard
            )


        for eventName in eventNames {

            checkEvent(
                eventName,
                oldScoreboard: oldScoreboard,
                newScoreboard: newScoreboard
            )
        }
    }


    // MARK: - Check One Event

    private func checkEvent(
        _ eventName: String,
        oldScoreboard: [ScoreboardSeason],
        newScoreboard: [ScoreboardSeason]
    ) {

        let oldPerformances =
            BeerGamePerformanceRanking
                .performances(
                    eventName: eventName,
                    scoreboard: oldScoreboard
                )


        let newPerformances =
            BeerGamePerformanceRanking
                .performances(
                    eventName: eventName,
                    scoreboard: newScoreboard
                )


        guard
            !oldPerformances.isEmpty,
            !newPerformances.isEmpty
        else {
            return
        }


        let timed =
            BeerGamePerformanceRanking
                .isTimed(
                    newPerformances
                )


        let oldSorted =
            BeerGamePerformanceRanking
                .sorted(
                    oldPerformances,
                    timed: timed
                )


        let newSorted =
            BeerGamePerformanceRanking
                .sorted(
                    newPerformances,
                    timed: timed
                )


        guard
            let oldRecord = oldSorted.first,
            let newRecord = newSorted.first
        else {
            return
        }


        // Must actually improve the record.

        guard
            let oldValue = oldRecord.sortValue,
            let newValue = newRecord.sortValue
        else {
            return
        }

        let recordWasBroken: Bool

        if timed {

            recordWasBroken =
                newValue < oldValue

        } else {

            recordWasBroken =
                newValue > oldValue
        }


        guard recordWasBroken else {
            return
        }


        sendRecordNotification(
            performance: newRecord
        )
    }


    // MARK: - Find Event Names

    private func allEventNames(
        in scoreboard: [ScoreboardSeason]
    ) -> [String] {

        var names =
            Set<String>()


        for season in scoreboard {

            for entry in season.entries {

                for event in entry.events {

                    let name =
                        event.event
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )


                    if !name.isEmpty {
                        names.insert(name)
                    }
                }
            }
        }


        return Array(names)
            .sorted()
    }


    // MARK: - Send Notification

    private func sendRecordNotification(
        performance: BeerGamePerformance
    ) {

        let content =
            UNMutableNotificationContent()


        content.title =
            "🏆 NEW BEER GAMES RECORD! 🏆"


        content.body =
            "\(performance.player) has just set a new \(performance.event) record with \(performance.result)!!!"


        content.sound =
            .default


        let request =
            UNNotificationRequest(
                identifier:
                    "beer-record-\(performance.event)-\(performance.player)-\(performance.year)-\(performance.result)",

                content:
                    content,

                trigger:
                    nil
            )


        UNUserNotificationCenter
            .current()
            .add(request) { error in

                if let error {

                    print(
                        "Unable to send record notification:",
                        error.localizedDescription
                    )

                } else {

                    print(
                        "🏆 Record notification:",
                        performance.player,
                        performance.event,
                        performance.result
                    )
                }
            }
    }
}
