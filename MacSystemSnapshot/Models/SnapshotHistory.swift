//
//  SnapshotHistory.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 08/09/2026.
//

import Foundation
enum SnapshotHistory {
    static let maximumCount = 10
    static func keepingLatest (
        _ snapshots: [SystemSnapshot]
    ) -> [SystemSnapshot] {
        var seenIDs = Set<UUID>()
        
        let uniqueSnapshots = snapshots.filter {
            seenIDs.insert($0.id).inserted
        }
        return Array(uniqueSnapshots.prefix(maximumCount))
    } 
}
