//
//  SnapshotFormatting.swift
//  MacSystemSnapshot
//
//  Created by Anna Granos on 07/09/2026.
//

import Foundation
enum SnapshotFormatting {
    static func memory(
        _ bytes: UInt64,
        locale: Locale = .current
    ) -> String {
        let gibibytes = Double(bytes) / 1_073_741_824

        let value = gibibytes.formatted(
            .number
                .precision(.fractionLength(0...1))
                .locale(locale)
        )

        return "\(value) GiB"
    }

    static func disk(
        _ bytes: UInt64,
        locale: Locale = .current
    ) -> String {
        let gigabytes = Double(bytes) / 1_000_000_000

        let value = gigabytes.formatted(
            .number
                .precision(.fractionLength(0...1))
                .locale(locale)
        )

        return "\(value) GB"
    }

    static func timestamp(_ date: Date) -> String {
        date.formatted(
            date: .abbreviated,
            time: .standard
        )
    }
    static func percentage(_ value: Double, locale: Locale = .current) -> String {
        value.formatted(.percent.precision(.fractionLength(0...1))
            .locale(locale))
    }
}
