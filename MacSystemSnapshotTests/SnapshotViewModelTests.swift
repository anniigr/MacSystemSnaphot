//
//  SnapshotViewModelTests.swift
//  MacSystemSnapshotTests
//
//  Created by Anna Granos on 08/09/2026.
//

import XCTest
import Foundation
@testable import MacSystemSnapshot

final class SnapshotViewModelTests: XCTestCase {
    @MainActor
    func testLaunchLoadsHistoryCapturesAndSavesNewSnapshot() async {
        let previous = SnapshotFixture.make()
        let fresh = SnapshotFixture.make()

        let provider = StubSystemInfoProvider(
            result: .success(fresh)
        )
        let store = InMemorySnapshotStore()
        store.storedSnapshots = [previous]

        let viewModel = SnapshotViewModel(
            provider: provider,
            store: store,
            exporter: SnapshotExporter()
        )

        viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.snapshots, [fresh, previous])
        XCTAssertEqual(viewModel.selectedSnapshot, fresh)
        XCTAssertEqual(store.storedSnapshots, [fresh, previous])
        XCTAssertNil(viewModel.persistenceErrorMessage)
    }

    @MainActor
    func testFailedRefreshPreservesHistoryAndSelection() async {
        let original = SnapshotFixture.make()

        let provider = StubSystemInfoProvider(
            result: .success(original)
        )
        let store = InMemorySnapshotStore()

        let viewModel = SnapshotViewModel(
            provider: provider,
            store: store,
            exporter: SnapshotExporter()
        )

        viewModel.loadIfNeeded()
        provider.result = .failure(.simulated)

        viewModel.refresh()

        XCTAssertEqual(viewModel.snapshots, [original])
        XCTAssertEqual(viewModel.selectedSnapshot, original)
        XCTAssertEqual(store.storedSnapshots, [original])
        XCTAssertNotNil(viewModel.refreshErrorMessage)
    }

    @MainActor
    func testFailedSaveKeepsCaptureAndRetryPersistsIt() async {
        let snapshot = SnapshotFixture.make()

        let provider = StubSystemInfoProvider(
            result: .success(snapshot)
        )
        let store = InMemorySnapshotStore()
        store.saveError = .simulated

        let viewModel = SnapshotViewModel(
            provider: provider,
            store: store,
            exporter: SnapshotExporter()
        )

        viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.selectedSnapshot, snapshot)
        XCTAssertTrue(store.storedSnapshots.isEmpty)
        XCTAssertNotNil(viewModel.persistenceErrorMessage)

        store.saveError = nil
        viewModel.retrySavingHistory()

        XCTAssertEqual(store.storedSnapshots, [snapshot])
        XCTAssertNil(viewModel.persistenceErrorMessage)
    }

    @MainActor
    func testFailedLoadProtectsHistoryAndRetryMergesCaptures() async {
        let previous = SnapshotFixture.make()
        let fresh = SnapshotFixture.make()

        let provider = StubSystemInfoProvider(
            result: .success(fresh)
        )
        let store = InMemorySnapshotStore()
        store.storedSnapshots = [previous]
        store.loadError = .simulated

        let viewModel = SnapshotViewModel(
            provider: provider,
            store: store,
            exporter: SnapshotExporter()
        )

        viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.snapshots, [fresh])
        XCTAssertEqual(store.storedSnapshots, [previous])
        XCTAssertEqual(store.saveAttempts, 0)
        XCTAssertNotNil(viewModel.persistenceErrorMessage)

        store.loadError = nil
        viewModel.retrySavingHistory()

        XCTAssertEqual(viewModel.snapshots, [fresh, previous])
        XCTAssertEqual(store.storedSnapshots, [fresh, previous])
        XCTAssertEqual(viewModel.selectedSnapshot, fresh)
        XCTAssertNil(viewModel.persistenceErrorMessage)
    }

    @MainActor
    func testSelectingPreviousSnapshotDoesNotCaptureOrSave() async {
        let previous = SnapshotFixture.make()
        let fresh = SnapshotFixture.make()

        let provider = StubSystemInfoProvider(
            result: .success(fresh)
        )
        let store = InMemorySnapshotStore()
        store.storedSnapshots = [previous]

        let viewModel = SnapshotViewModel(
            provider: provider,
            store: store,
            exporter: SnapshotExporter()
        )

        viewModel.loadIfNeeded()
        let saveAttemptsBeforeSelection = store.saveAttempts

        viewModel.selectedSnapshotID = previous.id

        XCTAssertEqual(viewModel.selectedSnapshot, previous)
        XCTAssertEqual(viewModel.snapshots, [fresh, previous])
        XCTAssertEqual(store.saveAttempts, saveAttemptsBeforeSelection)
    }
}
