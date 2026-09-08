//
//  SnapshotDetailView.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 08/09/2026.
//

import SwiftUI

struct SnapshotDetailView: View {
    let snapshot: SystemSnapshot

    private let columns = [
        GridItem(
            .adaptive(minimum: 300),
            spacing: 16,
            alignment: .top
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            deviceHeader

            LazyVGrid(columns: columns, spacing: 16) {
                systemSection
                memorySection
            }

            storageSection

            Label {
                Text(
                    "Values reflect the capture time. "
                    + "Refresh to collect a new snapshot."
                )
            } icon: {
                Image(systemName: "info.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var deviceHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "desktopcomputer")
                .font(.system(size: 30))
                .foregroundStyle(Color.accentColor)
                .frame(width: 64, height: 64)
                .background(
                    Color.accentColor.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(snapshot.deviceName)
                    .font(.title2.weight(.semibold))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Captured")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    SnapshotFormatting.timestamp(snapshot.capturedAt)
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var systemSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                detailRow(
                    "macOS version",
                    value: snapshot.macOSVersion
                )

                detailRow(
                    "Architecture",
                    value: snapshot.processorArchitecture
                )

                detailRow(
                    "Active processors",
                    value: snapshot.activeProccessorCount.formatted()
                )

                Text("Processor count refers to active logical processors.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 150,
                alignment: .topLeading
            )
            .padding(12)
        } label: {
            Label("System", systemImage: "cpu")
                .font(.headline)
        }
    }

    private var memorySection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text(
                    SnapshotFormatting.memory(
                        snapshot.physicalMemoryBytes
                    )
                )
                .font(
                    .system(
                        size: 34,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .textSelection(.enabled)

                Text("Installed physical memory")
                    .font(.subheadline)

                Text("Total RAM capacity, not current memory usage.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 150,
                alignment: .topLeading
            )
            .padding(12)
        } label: {
            Label("Memory", systemImage: "memorychip")
                .font(.headline)
        }
    }

    private var storageSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Available")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(
                            SnapshotFormatting.disk(
                                snapshot.availableDiskBytes
                            )
                        )
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .textSelection(.enabled)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(
                            SnapshotFormatting.disk(
                                snapshot.totalDiskBytes
                            )
                        )
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .textSelection(.enabled)
                    }
                }

                if let fraction = snapshot.availableDiskFraction {
                    ProgressView(value: fraction, total: 1)
                        .progressViewStyle(.linear)
                        .tint(Color.accentColor)
                        .accessibilityLabel("Available disk space")
                        .accessibilityValue(
                            SnapshotFormatting.percentage(fraction)
                        )

                    Text(
                        "\(SnapshotFormatting.percentage(fraction)) available"
                    )
                    .font(.callout.weight(.medium))
                    .monospacedDigit()
                } else {
                    Text("Available disk percentage could not be calculated.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Divider()

                Text(
                    "Volume containing the app's home directory. "
                    + "Available space is reported by the file system "
                    + "and may differ from Finder's estimate."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Storage", systemImage: "internaldrive")
                .font(.headline)
        }
    }

    private func detailRow(
        _ title: String,
        value: String
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}
