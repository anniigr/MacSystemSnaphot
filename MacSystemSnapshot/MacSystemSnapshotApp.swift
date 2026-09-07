//
//  MacSystemSnapshotApp.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import SwiftUI

@main
struct MacSystemSnapshotApp: App {
    @StateObject private var viewModel = SnapshotViewModel(
        provider: SystemInfoService()
    )

    var body: some Scene {
        Window("Mac System Snapshot", id: "main") {
            ContentView(viewModel: viewModel)
        }
        .defaultSize(width: 680, height: 480)
    }
}
