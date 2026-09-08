//
//  SnapshotStoring.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 08/09/2026.
//

import Foundation
@MainActor
protocol SnapshotStoring {
    func load() throws -> [SystemSnapshot]
    func save(_ snapshots: [SystemSnapshot]) throws
}
