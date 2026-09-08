//
//  SnapshotViewModel.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import Foundation
import Combine

@MainActor
final class SnapshotViewModel: ObservableObject {
    @Published private(set) var snapshots: [SystemSnapshot] = []
    @Published var selectedSnapshotID: UUID?

    @Published private(set) var refreshErrorMessage: String?
    @Published private(set) var persistenceErrorMessage: String?
    @Published private(set) var exportErrorMessage: String?
    @Published private(set) var exportMessage: String?

    private let provider: any SystemInfoProviding
    private let store: any SnapshotStoring
    private let exporter: SnapshotExporter

    private var didLoad = false
    private var didReadHistory = false

    var selectedSnapshot: SystemSnapshot? {
        snapshots.first {
            $0.id == selectedSnapshotID
        }
    }

    init(
        provider: any SystemInfoProviding,
        store: any SnapshotStoring,
        exporter: SnapshotExporter
    ) {
        self.provider = provider
        self.store = store
        self.exporter = exporter
    }

    func loadIfNeeded() {
        guard !didLoad else {
            return
        }

        didLoad = true

        do {
            snapshots = SnapshotHistory.keepingLatest(try store.load())
            selectedSnapshotID = snapshots.first?.id
            didReadHistory = true
        } catch {
            persistenceErrorMessage = historyReadMessage(for: error)
        }

        refresh()
    }

    func refresh() {
        let newSnapshot: SystemSnapshot

        do {
            newSnapshot = try provider.captureSnapshot()
        } catch {
            refreshErrorMessage = """
            \(error.localizedDescription) Existing snapshots are unchanged.
            """
            return
        }

        snapshots = SnapshotHistory.keepingLatest(
            [newSnapshot] + snapshots
        )
        selectedSnapshotID = newSnapshot.id

        refreshErrorMessage = nil
        exportErrorMessage = nil
        exportMessage = nil

        if didReadHistory {
            saveHistory()
        }
    }

    func retrySavingHistory() {
        if !didReadHistory {
            do {
                let storedSnapshots = try store.load()

                snapshots = SnapshotHistory.keepingLatest(
                    snapshots + storedSnapshots
                )

                if selectedSnapshotID == nil {
                    selectedSnapshotID = snapshots.first?.id
                }

                didReadHistory = true
            } catch {
                persistenceErrorMessage = historyReadMessage(for: error)
                return
            }
        }

        saveHistory()
    }

    func exportSelectedSnapshot() {
        guard let snapshot = selectedSnapshot else {
            return
        }

        exportErrorMessage = nil
        exportMessage = nil

        do {
            let didExport = try exporter.export(snapshot)

            if didExport {
                exportMessage = """
                Exported snapshot captured \
                \(SnapshotFormatting.timestamp(snapshot.capturedAt)).
                """
            }
        } catch {
            exportErrorMessage = error.localizedDescription
        }
    }

    private func saveHistory() {
        do {
            try store.save(snapshots)
            persistenceErrorMessage = nil
        } catch {
            persistenceErrorMessage = """
            History could not be saved. Changes remain in memory and may \
            be lost when the app quits. \(error.localizedDescription)
            """
        }
    }

    private func historyReadMessage(for error: any Error) -> String {
        """
        History could not be loaded. The existing file was left unchanged. \
        New snapshots remain in memory until history can be loaded and saved. \
        \(error.localizedDescription)
        """
    }
}
