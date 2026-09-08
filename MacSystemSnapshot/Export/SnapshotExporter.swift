//
//  SnapshotExporter.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 08/09/2026.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
struct SnapshotExporter {
    func export(_ snapshot: SystemSnapshot) throws -> Bool {
        let data = try SnapshotJSON.encode(snapshot)

        let panel = NSSavePanel()
        panel.title = "Export Snapshot"
        panel.message = "Choose where to save the selected snapshot."
        panel.prompt = "Export"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = "snapshot-\(snapshot.id.uuidString).json"

        guard panel.runModal() == .OK else {
            return false
        }

        guard let url = panel.url else {
            throw SnapshotExportError.missingDestination
        }

        try data.write(to: url, options: .atomic)

        return true
    }
}

enum SnapshotExportError: LocalizedError {
    case missingDestination

    var errorDescription: String? {
        switch self {
        case .missingDestination:
            return "No destination was selected for the exported snapshot."
        }
    }
}
