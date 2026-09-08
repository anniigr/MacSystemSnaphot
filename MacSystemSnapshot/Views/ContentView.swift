//
//  ContentView.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SnapshotViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                pageHeader

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(errorMessage)
                }

                if let snapshot = viewModel.snapshot {
                    SnapshotDetailView(snapshot: snapshot)
                } else {
                    emptyState
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(
            minWidth: 600,
            maxWidth: .infinity,
            minHeight: 520,
            maxHeight: .infinity
        )
        .background(Color(nsColor: .windowBackgroundColor))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.refreshSnapshot()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Capture a new system snapshot (Command-R)")
            }
        }
        .task {
            viewModel.loadIfNeeded()
        }
    }

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("System overview")
                .font(.largeTitle.weight(.bold))

            Text("Your Mac's configuration and available storage.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                "No snapshot available",
                systemImage: "desktopcomputer"
            )
        } description: {
            Text(
                "Use Refresh to collect system information "
                + "from this Mac."
            )
        } actions: {
            Button("Refresh") {
                viewModel.refreshSnapshot()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Could not refresh")
                    .font(.headline)

                Text(message)
                    .font(.callout)
                    .textSelection(.enabled)

                if viewModel.snapshot != nil {
                    Text("Showing the last successful snapshot.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Retry") {
                viewModel.refreshSnapshot()
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(
            Color.orange.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    Color.orange.opacity(0.25),
                    lineWidth: 1
                )
        }
    }
}
