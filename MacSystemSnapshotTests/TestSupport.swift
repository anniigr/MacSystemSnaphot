//
//  TestSupport.swift
//  MacSystemSnapshotTests
//
//  Created by Anna Granos on 08/09/2026.
//
import Foundation
@testable import MacSystemSnapshot

@MainActor
enum SnapshotFixture {
    static func make(
        id: UUID = UUID(),
        capturedAt: Date = Date(
            timeIntervalSince1970: 1_700_000_000.125
        ),
        totalDiskBytes: UInt64 = 1_000_000_000_000,
        availableDiskBytes: UInt64 = 250_000_000_000
    ) -> SystemSnapshot {
        SystemSnapshot(
            id: id,
            capturedAt: capturedAt,
            activeProccessorCount: 8,
            deviceName: "Test Mac",
            macOSVersion: "14.0.0",
            processorArchitecture: "arm64",
            physicalMemoryBytes: 17_179_869_184,
            totalDiskBytes: totalDiskBytes,
            availableDiskBytes: availableDiskBytes
        )
    }
}

enum TestFailure: Error {
    case simulated
}

final class StubSystemInfoProvider: SystemInfoProviding {
    var result: Result<SystemSnapshot, TestFailure>

    init(result: Result<SystemSnapshot, TestFailure>) {
        self.result = result
    }

    func captureSnapshot() throws -> SystemSnapshot {
        try result.get()
    }
}

@MainActor
final class InMemorySnapshotStore: SnapshotStoring {
    var storedSnapshots: [SystemSnapshot] = []
    var loadError: TestFailure?
    var saveError: TestFailure?

    private(set) var saveAttempts = 0

    func load() throws -> [SystemSnapshot] {
        if let loadError = loadError {
            throw loadError
        }

        return storedSnapshots
    }

    func save(_ snapshots: [SystemSnapshot]) throws {
        saveAttempts += 1

        if let saveError = saveError {
            throw saveError
        }

        storedSnapshots = snapshots
    }
}

@MainActor
func withTemporaryStore(
    _ body: @MainActor (JSONSnapshotStore, URL) throws -> Void
) throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(
            "MacSystemSnapshotTests-\(UUID().uuidString)",
            isDirectory: true
        )

    try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: true
    )

    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let store = JSONSnapshotStore(directory: directory)
    try body(store, directory)
}
