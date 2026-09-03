import Foundation

struct YearEndRosterParser {

    private static let keeperMarker = "__LDBL_KEEPER__"
    private static let removedMarker = "__LDBL_REMOVED__"

    // MARK: - 2025 Hard-Coded Keepers

    private static let keepers2025: [String: String] = [
        "Tony": "Brock Bowers",
        "Hancharik": "Bucky Irving",
        "Yuhas": "Lamar Jackson",
        "Baran": "Malik Nabers",
        "Penksa": "Jayden Daniels",
        "Darah": "Baker Mayfield",
        "Todd": "Brian Thomas Jr.",
        "Nate": "Jaxon Smith-Njigba",
        "Sub": "Christian McCaffery",
        "Brandon": "Trey McBride"
    ]

    // MARK: - 2025 Hard-Coded Removed Players

    private static let removed2025: [String: Set<String>] = [

        "Tony": [
            "Jameson Williams",
            "Austin Ekeler",
            "Cedric Tillman",
            "LIONS",
            "Brandon Aiyuk",
            "Brandon McManus"
        ],

        "Hancharik": [
            "Kyren Williams",
            "Matthew Golden",
            "David Njoku",
            "Joe Mixon",
            "Jk Dobbins",
            "Jayden Higgins",
            "RAVENS",
            "Darren Waller"
        ],

        "Yuhas": [
            "Tyreek Hill",
            "Travis Hunter",
            "Kaleb Johnson",
            "Tank Bigsby",
            "Jayden Reed",
            "Marvin Mims Jr.",
            "JETS",
            "Cam Little"
        ],

        "Baran": [
            "Garrett Wilson",
            "Malik Nabers",
            "Jerome Ford",
            "Xavier Legette",
            "JJ McCarthy",
            "Cairo Santos"
        ],

        "Penksa": [
            "Chuba Hubbard",
            "James Conner",
            "Calvin Ridley",
            "Jerry Jeudy",
            "Evan Engram",
            "Cooper Kupp",
            "Jayden Daniels",
            "Nick Chubb",
            "Dak Prescott",
            "Chris Boswell",
            "VIKINGS",
            "Najee Harris"
        ],

        "Darah": [
            "Mike Evans",
            "Tucker Kraft",
            "Josh Downs",
            "Bhayshul Tuten",
            "Chase McGlaughlin",
            "49ERS",
            "Michael Penix Jr."
        ],

        "Todd": [
            "Davante Adams",
            "TJ Hockenson",
            "Isiah Pacheco",
            "Tyrone Tracy",
            "Keon Coleman",
            "STEELERS",
            "Jake Bates",
            "Jared Goff"
        ],

        "Nate": [
            "Rashid Shaheed",
            "CJ Stroud",
            "Dallas Goedert",
            "Jayden Blue"
        ],

        "Sub": [
            "Brock Purdy",
            "Darnell Mooney",
            "Tyler Algier",
            "Justin Fields",
            "PATRIOTS",
            "Tyler Bass"
        ],

        "Brandon": [
            "Xavier Worthy",
            "Kyler Murray",
            "Bo Nix",
            "Braelon Allen",
            "Coleston Loveland",
            "CARDINALS",
            "Jake Elliot"
        ]
    ]

    // MARK: - Parse

    static func parse(
        rows: [[String]],
        fallbackYear: Int
    ) -> YearEndRosterSeason? {

        guard let headerIndex = rows.firstIndex(
            where: { row in
                cleanMarkers(
                    value(row, 0)
                ).text.uppercased() == "ROUND"
            }
        ) else {
            return nil
        }

        let header = rows[headerIndex]

        // MARK: Determine Year

        let year =
            rows
                .prefix(headerIndex + 1)
                .flatMap { $0 }
                .compactMap {
                    Int(cleanMarkers($0).text)
                }
                .first {
                    (2000...2100).contains($0)
                }
            ?? fallbackYear

        var managers: [YearEndRosterManager] = []

        // MARK: Manager Columns

        for column in 1..<header.count {

            let rawManager = cleanMarkers(
                value(header, column)
            ).text

            guard !rawManager.isEmpty else {
                continue
            }

            let manager =
                ManagerNameNormalizer.normalize(
                    rawManager
                )

            var draftPicks: [YearEndRosterPlayer] = []
            var acquired: [YearEndRosterAcquiredPlayer] = []

            // MARK: Players

            for row in rows.dropFirst(headerIndex + 1) {

                let marked = cleanMarkers(
                    value(row, column)
                )

                guard !marked.text.isEmpty else {
                    continue
                }

                let player = marked.text

                let roundText = cleanMarkers(
                    value(row, 0)
                ).text

                // Automatic formatting from Apps Script.
                var isKeeper = marked.isKeeper
                var isRemoved = marked.isRemoved

                // MARK: 2025 Guaranteed Formatting

                if year == 2025 {

                    if let keeper =
                        keepers2025[manager],
                       normalized(player) ==
                        normalized(keeper) {

                        isKeeper = true
                    }

                    if let removed =
                        removed2025[manager] {

                        let removedNormalized =
                            Set(
                                removed.map {
                                    normalized($0)
                                }
                            )

                        if removedNormalized.contains(
                            normalized(player)
                        ) {
                            isRemoved = true
                        }
                    }
                }

                // MARK: Draft Pick

                if let round = Int(roundText) {

                    draftPicks.append(
                        YearEndRosterPlayer(
                            round: round,
                            player: player,
                            isKeeper: isKeeper,
                            isRemoved: isRemoved
                        )
                    )

                } else {

                    // MARK: Acquired

                    acquired.append(
                        YearEndRosterAcquiredPlayer(
                            player: player,
                            isKeeper: isKeeper,
                            isRemoved: isRemoved
                        )
                    )
                }
            }

            guard
                !draftPicks.isEmpty ||
                !acquired.isEmpty
            else {
                continue
            }

            managers.append(
                YearEndRosterManager(
                    manager: manager,
                    draftPicks:
                        draftPicks.sorted {
                            $0.round < $1.round
                        },
                    acquiredPlayers: acquired
                )
            )
        }

        guard !managers.isEmpty else {
            return nil
        }

        return YearEndRosterSeason(
            year: year,
            managers: managers
        )
    }

    // MARK: - Marker Parsing

    private static func cleanMarkers(
        _ text: String
    ) -> (
        text: String,
        isKeeper: Bool,
        isRemoved: Bool
    ) {

        let cleaned = clean(text)

        let isKeeper =
            cleaned.contains(
                keeperMarker
            )

        let isRemoved =
            cleaned.contains(
                removedMarker
            )

        let plain =
            cleaned
                .replacingOccurrences(
                    of: keeperMarker,
                    with: ""
                )
                .replacingOccurrences(
                    of: removedMarker,
                    with: ""
                )
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        return (
            text: plain,
            isKeeper: isKeeper,
            isRemoved: isRemoved
        )
    }

    // MARK: - Name Matching

    private static func normalized(
        _ value: String
    ) -> String {

        value
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
            .replacingOccurrences(
                of: "’",
                with: "'"
            )
    }

    // MARK: - Helpers

    private static func clean(
        _ text: String
    ) -> String {

        text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private static func value(
        _ row: [String],
        _ index: Int
    ) -> String {

        guard row.indices.contains(index) else {
            return ""
        }

        return clean(row[index])
    }
}
