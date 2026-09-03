import Foundation
import UIKit
import UserNotifications

actor PushBackgroundRefreshService {

    static let shared = PushBackgroundRefreshService()

    private init() {}

    func refreshAfterRemoteChange() async -> UIBackgroundFetchResult {
        do {
            let freshData = try await SpreadsheetService.shared.fetchLeagueData()

            let newNews = await MainActor.run {
                LeagueNewsManager.shared.processFreshScoreboard(
                    freshData.payload.scoreboard
                )
            }

            do {
                try await LeagueDataCache.shared.save(
                    sheets: freshData.rawSheets
                )
            } catch {
                print(
                    "Push refresh fetched fresh data, but cache save failed:",
                    error.localizedDescription
                )
            }

            if !newNews.isEmpty {
                await scheduleLocalNotifications(for: newNews)
            }

            print(
                "Remote-change refresh complete. New league news:",
                newNews.count
            )

            return .newData
        } catch {
            print(
                "Remote-change refresh failed:",
                error.localizedDescription
            )

            return .failed
        }
    }

    private func scheduleLocalNotifications(
        for items: [LeagueNewsItem]
    ) async {
        let center = UNUserNotificationCenter.current()

        for item in items {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.message
            content.sound = .default
            content.userInfo = [
                "leagueNewsID": item.id,
                "leagueNewsType": item.type.rawValue
            ]

            let request = UNNotificationRequest(
                identifier: "ldbl-news-\(item.id)",
                content: content,
                trigger: nil
            )

            do {
                try await center.add(request)
            } catch {
                print(
                    "Unable to schedule league-news notification:",
                    error.localizedDescription
                )
            }
        }
    }
}
