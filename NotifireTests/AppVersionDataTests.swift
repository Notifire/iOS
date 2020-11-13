//
//  AppVersionDataTests.swift
//  NotifireTests
//
//  Created by David Bielik on 13/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest
@testable import Notifire

class AppVersionDataTests: XCTestCase {

    // MARK: - Util
    func commonComparison(_ version1: String, _ version2: String, expected result: ComparisonResult) {
        // Given
        // v1, v2
        // When
        let comparisonResult = AppVersionData.compareVersionsIgnoringPatch(version1: version1, version2: version2)
        // Then
        XCTAssert(comparisonResult == result)
    }

    // MARK: - Equal
    /// Test whether two equal versions result in `.orderedSame`
    func testCompareVersionsEqual() {
        let version = "1.0.0"
        commonComparison(
            version,
            version,
            expected: .orderedSame
        )
    }

    // MARK: - Descending
    /// Test whether descending major version results in `.orderedDescending`
    func testCompareVersionsDescendingMajor() {
        commonComparison(
            "2.0.0",
            "1.0.0",
            expected: .orderedDescending
        )
    }

    /// Test whether descending minor version results in `.orderedDescending`
    func testCompareVersionsDescendingMinor() {
        commonComparison(
            "1.1.0",
            "1.0.0",
            expected: .orderedDescending
        )
    }

    /// Test whether descending patch version results in `.orderedSame`
    func testCompareVersionsDescendingPatch() {
        commonComparison(
            "1.0.5",
            "1.0.0",
            expected: .orderedSame
        )
    }

    // MARK: - Ascending
    /// Test whether ascending major version results in `.orderedAscending`
    func testCompareVersionsAscendingMajor() {
        commonComparison(
            "1.0.0",
            "2.0.0",
            expected: .orderedAscending
        )
    }

    /// Test whether descending minor version results in `.orderedAscending`
    func testCompareVersionsAscendingMinor() {
        commonComparison(
            "1.0.0",
            "1.1.0",
            expected: .orderedAscending
        )
    }

    /// Test whether descending patch version results in `.orderedSame`
    func testCompareVersionsAscendingPatch() {
        commonComparison(
            "1.0.0",
            "1.0.5",
            expected: .orderedSame
        )
    }

    // MARK: - Without PATCH
    /// Test if the versions can be passed without the PATCH value.
    func testCompareVersionsWithoutPatchValueSame() {
        let version1 = "1.0.0"
        let version2 = "1.0"
        commonComparison(
            version1,
            version2,
            expected: .orderedSame
        )
        commonComparison(
            version2,
            version1,
            expected: .orderedSame
        )
    }

    /// Test if the versions passed without PATCH value result in `.orderedDescending`
    func testCompareVersionsWithoutPatchValueDescendingMinor() {
        let version1 = "1.1.0"
        let version2 = "1.0"
        commonComparison(
            version1,
            version2,
            expected: .orderedDescending
        )
        commonComparison(
            version2,
            version1,
            expected: .orderedAscending
        )
    }

    /// Test if the versions passed without PATCH value result in `.orderedDescending`
    func testCompareVersionsWithoutPatchValueDescendingMajor() {
        let version1 = "2.0.0"
        let version2 = "1.0"
        commonComparison(
            version1,
            version2,
            expected: .orderedDescending
        )
        commonComparison(
            version2,
            version1,
            expected: .orderedAscending
        )
    }

    // MARK: - Mixed
    /// Test if ascending major and minor version results in `.orderedAscending`
    func testCompareVersionsAscendingMajorMinor() {
        commonComparison(
            "1.0.0",    // remote
            "2.1.0",    // local
            expected: .orderedAscending
        )
    }

    /// Test if descending major and ascending minor version results in `.orderedDescending`
    func testCompareVersionsDescendingMajorAscendingMinor() {
        commonComparison(
            "2.0.0",    // remote
            "1.1.0",    // local
            expected: .orderedDescending
        )
    }

    /// Test if descending major and ascending patch version results in `.orderedDescending`
    func testCompareVersionsDescendingMajorAscendingPatch() {
        commonComparison(
            "2.0.0",    // remote
            "1.0.5",    // local
            expected: .orderedDescending
        )
    }
}
