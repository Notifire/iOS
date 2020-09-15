//
//  XCTestCase+Delay.swift
//  NotifireUITests
//
//  Created by David Bielik on 13/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest

extension XCTestCase {

    /// Add a non-blocking delay / sleep to the XCTestCase test execution.
    /// - Parameters:
    ///     - timeout: how much delay this function applies
    func delay(timeout: TimeInterval) {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
    }
}
