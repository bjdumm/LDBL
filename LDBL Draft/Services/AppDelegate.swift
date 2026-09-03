import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

extension Notification.Name {
    static let ldblRemoteDataChanged = Notification.Name(
        "ldblRemoteDataChanged"
    )
}

final class AppDelegate: NSObject,
                         UIApplicationDelegate,
                         UNUserNotificationCenterDelegate,
                         MessagingDelegate {

    private let topicName = "ldbl-managers"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        print("🚀 LDBL AppDelegate started")
        print("📦 Bundle ID:", Bundle.main.bundleIdentifier ?? "UNKNOWN")

        FirebaseApp.configure()

        print("🔥 Firebase configured")

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print(
                "🔔 Existing notification authorization status:",
                settings.authorizationStatus.rawValue
            )
        }

        let authorizationOptions: UNAuthorizationOptions = [
            .alert,
            .badge,
            .sound
        ]

        UNUserNotificationCenter.current().requestAuthorization(
            options: authorizationOptions
        ) { granted, error in

            if let error {
                print(
                    "❌ Notification permission request failed:",
                    error.localizedDescription
                )
            } else {
                print(
                    "🔔 Notification permission granted:",
                    granted
                )
            }

            DispatchQueue.main.async {
                print("📡 Calling registerForRemoteNotifications()")

                application.registerForRemoteNotifications()

                print("📡 Registration request submitted")

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 3
                ) {
                    print(
                        "📡 isRegisteredForRemoteNotifications:",
                        application.isRegisteredForRemoteNotifications
                    )

                    Messaging.messaging().token { token, error in
                        if let error {
                            print("❌ FCM TOKEN ERROR:", error.localizedDescription)
                            return
                        }

                        if let token {
                            print("🔥 CURRENT FCM TOKEN:")
                            print(token)
                            self.subscribeToTopic()
                        } else {
                            print("❌ Firebase returned no FCM token")
                        }
                    }
                }
            }
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("✅ APNs registration succeeded")

        let tokenString = deviceToken
            .map { String(format: "%02.2hhx", $0) }
            .joined()

        print("📱 APNs device token:", tokenString)

        Messaging.messaging().apnsToken = deviceToken
        print("🔥 APNs token assigned to Firebase Messaging")

        Messaging.messaging().token { token, error in
            if let error {
                print(
                    "❌ Unable to retrieve FCM token:",
                    error.localizedDescription
                )
                return
            }

            guard let token else {
                print("⚠️ Firebase returned an empty FCM token")
                return
            }

            print("🔥 FCM token:", token)
            self.subscribeToTopic()
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print(
            "❌ APNs registration failed:",
            error.localizedDescription
        )
    }

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken else {
            print("⚠️ Firebase registration token callback contained no token")
            return
        }

        print("🔥 Firebase registration token callback:", fcmToken)
        subscribeToTopic()
    }

    private func subscribeToTopic() {
        Messaging.messaging().subscribe(
            toTopic: topicName
        ) { error in
            if let error {
                print(
                    "❌ Unable to subscribe to LDBL topic:",
                    error.localizedDescription
                )
            } else {
                print(
                    "✅ Subscribed to Firebase topic:",
                    self.topicName
                )
            }
        }
    }

    // MARK: - Push handling

    private func isLeagueDataPush(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let type = userInfo["type"] as? String else {
            return false
        }

        return type == "sheet_update" ||
               type == "beer_event_winner" ||
               type == "beer_games_champion"
    }

    private func requestImmediateRefresh() {
        DispatchQueue.main.async {
            print("🔄 Requesting immediate league refresh")
            NotificationCenter.default.post(
                name: .ldblRemoteDataChanged,
                object: nil
            )
        }
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
            @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📨 LDBL PUSH RECEIVED:", userInfo)

        guard isLeagueDataPush(userInfo) else {
            print("⚠️ Push ignored because it is not an LDBL data notification")
            completionHandler(.noData)
            return
        }

        if application.applicationState == .active {
            print("🟢 App active — requesting immediate league refresh")
            requestImmediateRefresh()
            completionHandler(.newData)
        } else {
            print("🌙 App backgrounded — attempting background refresh")

            Task {
                let result = await PushBackgroundRefreshService.shared
                    .refreshAfterRemoteChange()

                print("✅ Background refresh finished:", result.rawValue)
                completionHandler(result)
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        print("🔔 Foreground notification received:", userInfo)

        // Visible Firebase alerts do not need to wait for a later foreground
        // transition. Refresh immediately so an event-winner/champion popup
        // can appear as soon as the sheet data is available.
        if isLeagueDataPush(userInfo) {
            requestImmediateRefresh()
        }

        // We intentionally suppress the system banner while the app is open;
        // the persistent in-app League News presentation is the foreground UI.
        completionHandler([])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler:
            @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        print("👆 User opened notification:", userInfo)

        if isLeagueDataPush(userInfo) {
            requestImmediateRefresh()
        }

        completionHandler()
    }
}
