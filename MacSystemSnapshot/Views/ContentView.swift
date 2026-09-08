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
        NavigationSplitView {
            historySidebar
                .navigationSplitViewColumnWidth(
                    min: 220,
                    ideal: 250,
                    max: 300
                )
        } detail: {
            detailContent
        }
        .frame(
            minWidth: 820,
            maxWidth: .infinity,
            minHeight: 560,
            maxHeight: .infinity
        )
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    viewModel.refresh()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .help("Capture and save a new snapshot")

                Button {
                    viewModel.exportSelectedSnapshot()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(viewModel.selectedSnapshot == nil)
                .help("Export the selected snapshot as JSON")
            }
        }
        .task {
            viewModel.loadIfNeeded()
        }
    }

    private var historySidebar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("History")
                    .font(.headline)

                Spacer()

                Text(
                    "\(viewModel.snapshots.count)/\(SnapshotHistory.maximumCount)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(16)

            List(selection: $viewModel.selectedSnapshotID) {
                ForEach(viewModel.snapshots) { snapshot in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(
                            SnapshotFormatting.timestamp(
                                snapshot.capturedAt
                            )
                        )
                        .font(.callout.weight(.medium))
                        .lineLimit(2)

                        Text(
                            "\(SnapshotFormatting.disk(snapshot.availableDiskBytes)) available"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    .tag(snapshot.id)
                }
            }
            .listStyle(.sidebar)
            .overlay {
                if viewModel.snapshots.isEmpty {
                    Text("No snapshots yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Latest ten captures, newest first.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(12)
        }
    }

    private var detailContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Snapshot details")
                        .font(.largeTitle.weight(.bold))

                    Text("Select a capture from history or create a new one.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let message = viewModel.refreshErrorMessage {
                    errorBanner(
                        "Could not refresh",
                        message: message,
                        buttonTitle: "Retry"
                    ) {
                        viewModel.refresh()
                    }
                }

                if let message = viewModel.persistenceErrorMessage {
                    errorBanner(
                        "History needs attention",
                        message: message,
                        buttonTitle: "Retry save"
                    ) {
                        viewModel.retrySavingHistory()
                    }
                }

                if let message = viewModel.exportErrorMessage {
                    errorBanner(
                        "Could not export",
                        message: message,
                        buttonTitle: "Retry export"
                    ) {
                        viewModel.exportSelectedSnapshot()
                    }
                }

                if let message = viewModel.exportMessage {
                    Label(message, systemImage: "checkmark.circle")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if let snapshot = viewModel.selectedSnapshot {
                    SnapshotDetailView(snapshot: snapshot)
                } else {
                    emptyState
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(minWidth: 540)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                "No snapshot selected",
                systemImage: "desktopcomputer"
            )
        } description: {
            Text("Select a saved capture or use Refresh to create one.")
        } actions: {
            Button("Refresh") {
                viewModel.refresh()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
    }

    private func errorBanner(
        _ title: String,
        message: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                title,
                systemImage: "exclamationmark.triangle.fill"
            )
            .font(.headline)

            Text(message)
                .font(.callout)
                .textSelection(.enabled)

            Button(buttonTitle, action: action)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
