//
//  NotifireUITests.swift
//  NotifireUITests
//
//  Created by David Bielik on 13/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest

class NotifireUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
