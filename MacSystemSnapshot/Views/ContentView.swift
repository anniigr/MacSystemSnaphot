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
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mac System Snapshot")
                        .font(.title2.bold())

                    Text("A snapshot of your Mac's system information.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    viewModel.refreshSnapshot()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage = viewModel.errorMessage {
                        Label {
                            Text(errorMessage)
                                .textSelection(.enabled)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let snapshot = viewModel.snapshot {
                        snapshotDetails(snapshot)
                    } else {
                        Text("No snapshot available. Click Refresh to try again.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .frame(
            minWidth: 560,
            maxWidth: .infinity,
            minHeight: 420,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .task {
            viewModel.loadIfNeeded()
        }
    }

    private func snapshotDetails(
        _ snapshot: SystemSnapshot
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            infoRow("Device name", value: snapshot.deviceName)

            infoRow(
                "macOS version",
                value: snapshot.macOSVersion
            )

            infoRow(
                "Processor architecture",
                value: snapshot.processorArchitecture
            )

            infoRow(
                "Active processors",
                value: String(snapshot.activeProccessorCount)
            )

            infoRow(
                "Physical memory",
                value: SnapshotFormatting.memory(
                    snapshot.physicalMemoryBytes
                )
            )

            infoRow(
                "Total disk space",
                value: SnapshotFormatting.disk(
                    snapshot.totalDiskBytes
                )
            )

            infoRow(
                "Available disk space",
                value: SnapshotFormatting.disk(
                    snapshot.availableDiskBytes
                )
            )

            Divider()

            infoRow(
                "Last refreshed",
                value: SnapshotFormatting.timestamp(
                    snapshot.capturedAt
                )
            )

            Text("Disk values describe the volume containing the app's home directory.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func infoRow(
        _ title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 170, alignment: .leading)

            Text(value)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
