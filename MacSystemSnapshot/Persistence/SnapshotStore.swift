//
//  SnapshotStore.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 08/09/2026.
//

import Foundation
struct JSONSnapshotStore: SnapshotStoring {
    private let directory: URL?
    init(directory: URL? = nil){
        self.directory = directory
    }
    
    func load() throws -> [SystemSnapshot] {
        let url = try historyFileURL()
        let data : Data
        
        do {
            data = try Data(contentsOf: url)
        } catch let error as CocoaError
            where error.code == .fileReadNoSuchFile {
            return []
        }
        
        let snapshots = try SnapshotJSON.decode([SystemSnapshot].self, from: data)
        try validate(snapshots)
        return SnapshotHistory.keepingLatest(snapshots)
        
        
    }
    func save(_ snapshots: [SystemSnapshot]) throws {
        let limitedSnapshots = SnapshotHistory.keepingLatest(snapshots)
        try validate(snapshots)
        
        let data = try SnapshotJSON.encode(limitedSnapshots)
        let url = try historyFileURL()
        
        try data.write(to: url, options: .atomic)
        
    }
    private func historyFileURL() throws -> URL {
        let fileManager = FileManager.default
        let storageDirectory: URL

        if let directory = directory {
            storageDirectory = directory
        } else {
            let applicationSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            storageDirectory = applicationSupport.appendingPathComponent(
                "MacSystemSnapshot",
                isDirectory: true
            )
        }

        try fileManager.createDirectory(
            at: storageDirectory,
            withIntermediateDirectories: true
        )

        return storageDirectory.appendingPathComponent("snapshots.json")
    }

    private func validate(_ snapshots: [SystemSnapshot]) throws {
        let uniqueIDs = Set(snapshots.map(\.id))

        guard uniqueIDs.count == snapshots.count else {
            throw SnapshotStorageError.invalidHistory
        }

        guard snapshots.allSatisfy({
            $0.activeProccessorCount > 0
                && $0.physicalMemoryBytes > 0
                && $0.totalDiskBytes > 0
                && $0.availableDiskBytes <= $0.totalDiskBytes
        }) else {
            throw SnapshotStorageError.invalidHistory
        }
    }
}

enum SnapshotStorageError: LocalizedError {
    case invalidHistory

    var errorDescription: String? {
        switch self {
        case .invalidHistory:
            return "The history file contains invalid or duplicate snapshots."
        }
    }
}
    

