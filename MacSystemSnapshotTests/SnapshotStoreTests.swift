//
//  SnapshotStoreTests.swift
//  MacSystemSnapshotTests
//
//  Created by Anna Granos on 08/09/2026.
//

import XCTest
import Foundation
@testable import MacSystemSnapshot

final class SnapshotStoreTests: XCTestCase {
    @MainActor
    func testMissingHistoryReturnsEmptyArray() async throws {
        try withTemporaryStore { store, _ in
            let snapshots = try store.load()

            XCTAssertTrue(snapshots.isEmpty)
        }
    }

    @MainActor
    func testSaveAndReloadPersistsOnlyTenSnapshots() async throws {
        try withTemporaryStore { store, directory in
            let snapshots = (0..<12).map { _ in
                SnapshotFixture.make()
            }

            try store.save(snapshots)

            let anotherStore = JSONSnapshotStore(directory: directory)
            let restored = try anotherStore.load()

            XCTAssertEqual(
                restored,
                Array(snapshots.prefix(10))
            )
        }
    }

    @MainActor
    func testCorruptJSONThrowsWithoutChangingFile() async throws {
        try withTemporaryStore { store, directory in
            let fileURL = directory.appendingPathComponent(
                "snapshots.json"
            )
            let invalidData = Data("not valid JSON".utf8)

            try invalidData.write(to: fileURL)

            XCTAssertThrowsError(try store.load())

            let dataAfterLoad = try Data(contentsOf: fileURL)
            XCTAssertEqual(dataAfterLoad, invalidData)
        }
    }

    @MainActor
    func testHistoryRejectsImpossibleDiskValues() async throws {
        try withTemporaryStore { store, directory in
            let invalidSnapshot = SnapshotFixture.make(
                totalDiskBytes: 100,
                availableDiskBytes: 200
            )

            let fileURL = directory.appendingPathComponent(
                "snapshots.json"
            )

            let data = try SnapshotJSON.encode([invalidSnapshot])
            try data.write(to: fileURL)

            XCTAssertThrowsError(try store.load()) { error in
                XCTAssertTrue(error is SnapshotStorageError)
            }
        }
    }
}
