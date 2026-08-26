//
//  LeagueDataCache.swift
//  LDBL Draft
//

import Foundation


actor LeagueDataCache {

    static let shared =
        LeagueDataCache()


    private init() {}


    // MARK: - Cache Container

    struct CachedLeagueData: Codable {

        let lastUpdated: Date

        let sheets:
            [String: [[String]]]
    }


    // MARK: - Cache Location

    private var cacheURL: URL {

        get throws {

            let fileManager =
                FileManager.default


            let applicationSupport =
                try fileManager.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )


            let folder =
                applicationSupport
                    .appendingPathComponent(
                        "LDBL",
                        isDirectory: true
                    )


            if !fileManager
                .fileExists(
                    atPath: folder.path
                ) {

                try fileManager
                    .createDirectory(
                        at: folder,
                        withIntermediateDirectories: true
                    )
            }


            return folder
                .appendingPathComponent(
                    "league-data-cache.json"
                )
        }
    }


    // MARK: - Load

    func load()
        throws -> CachedLeagueData? {

        let url =
            try cacheURL


        guard FileManager.default
            .fileExists(
                atPath: url.path
            )
        else {
            return nil
        }


        let data =
            try Data(
                contentsOf: url
            )


        return try JSONDecoder()
            .decode(
                CachedLeagueData.self,
                from: data
            )
    }


    // MARK: - Save

    func save(
        sheets: [String: [[String]]]
    ) throws {

        let cachedData =
            CachedLeagueData(
                lastUpdated: Date(),
                sheets: sheets
            )


        let encoder =
            JSONEncoder()


        let data =
            try encoder.encode(
                cachedData
            )


        let url =
            try cacheURL


        try data.write(
            to: url,
            options: .atomic
        )
    }


    // MARK: - Clear

    func clear() throws {

        let url =
            try cacheURL


        guard FileManager.default
            .fileExists(
                atPath: url.path
            )
        else {
            return
        }


        try FileManager.default
            .removeItem(
                at: url
            )
    }
}
