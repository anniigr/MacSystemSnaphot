//
//  SnapshotLogicTests.swift
//  MacSystemSnapshotTests
//
//  Created by Anna Granos on 08/09/2026.
//

import XCTest
import Foundation
@testable import MacSystemSnapshot

final class SnapshotLogicTests: XCTestCase {
    @MainActor
    func testMemoryFormattingUsesBinaryUnits() async {
        let locale = Locale(identifier: "en_US")

        XCTAssertEqual(
            SnapshotFormatting.memory(17_179_869_184, locale: locale),
            "16 GiB"
        )

        XCTAssertEqual(
            SnapshotFormatting.memory(0, locale: locale),
            "0 GiB"
        )
    }

    @MainActor
    func testDiskFormattingUsesDecimalUnitsAndRounding() async {
        let locale = Locale(identifier: "en_US")

        XCTAssertEqual(
            SnapshotFormatting.disk(512_000_000_000, locale: locale),
            "512 GB"
        )

        XCTAssertEqual(
            SnapshotFormatting.disk(1_260_000_000, locale: locale),
            "1.3 GB"
        )
    }

    @MainActor
    func testAvailableFractionHandlesBoundariesAndInvalidData() async throws {
        let quarter = SnapshotFixture.make(
            totalDiskBytes: 100,
            availableDiskBytes: 25
        )

        XCTAssertEqual(
            try XCTUnwrap(quarter.availableDiskFraction),
            0.25,
            accuracy: 0.000_001
        )

        XCTAssertEqual(
            SnapshotFixture.make(
                totalDiskBytes: 100,
                availableDiskBytes: 0
            ).availableDiskFraction,
            0
        )

        XCTAssertEqual(
            SnapshotFixture.make(
                totalDiskBytes: 100,
                availableDiskBytes: 100
            ).availableDiskFraction,
            1
        )

        XCTAssertNil(
            SnapshotFixture.make(
                totalDiskBytes: 0,
                availableDiskBytes: 0
            ).availableDiskFraction
        )

        XCTAssertNil(
            SnapshotFixture.make(
                totalDiskBytes: 100,
                availableDiskBytes: 101
            ).availableDiskFraction
        )
    }

    @MainActor
    func testPercentageFormattingConvertsFractionToPercent() async {
        XCTAssertEqual(
            SnapshotFormatting.percentage(
                0.256,
                locale: Locale(identifier: "en_US")
            ),
            "25.6%"
        )
    }

    @MainActor
    func testJSONRoundTripPreservesSnapshotFields() async throws {
        let original = SnapshotFixture.make()

        let data = try SnapshotJSON.encode(original)
        let restored = try SnapshotJSON.decode(
            SystemSnapshot.self,
            from: data
        )

        XCTAssertEqual(restored, original)

        let object = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )

        let timestamp = try XCTUnwrap(
            object["capturedAt"] as? NSNumber
        )

        XCTAssertEqual(
            timestamp.doubleValue,
            original.capturedAt.timeIntervalSince1970 * 1_000,
            accuracy: 0.001
        )

        XCTAssertNil(object["availableDiskFraction"])
    }

    @MainActor
    func testHistoryKeepsFirstTenRecordsInCaptureOrder() async {
        let snapshots = (0..<12).map { index in
            SnapshotFixture.make(
                capturedAt: Date(
                    timeIntervalSince1970: Double(index)
                )
            )
        }

        let result = SnapshotHistory.keepingLatest(snapshots)

        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result, Array(snapshots.prefix(10)))
    }

    @MainActor
    func testHistoryDeduplicatesBeforeApplyingLimit() async {
        let snapshots = (0..<10).map { _ in
            SnapshotFixture.make()
        }

        let input = [snapshots[0]] + snapshots

        let result = SnapshotHistory.keepingLatest(input)

        XCTAssertEqual(result, snapshots)
    }
}
