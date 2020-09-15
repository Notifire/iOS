//
//  SSOUITests.swift
//  NotifireUITests
//
//  Created by David Bielik on 13/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest

class GoogleSSOUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        LaunchArgument.append(.resetKeychainData, to: &app.launchArguments)
        LaunchArgument.append(.turnOffAnimations, to: &app.launchArguments)
        app.launch()

        // wait for the app revealing animation
        delay(timeout: 8)
    }

    // MARK: - Cancelled login
    func testSuccessfulLogin() throws {
        let email = "notifire.sso.testicek@gmail.com"
        let password = "Kokotina1234"

        // Wait for the sign in system alert (Cancel / Continue)
        addUIInterruptionMonitor(withDescription: "Sign in") { alert -> Bool in
            if alert.buttons["Continue"].exists {
                alert.buttons["Continue"].tap()
                return true
            }
            return false
        }

        // Tap the sign in with google button
        app.buttons["Sign in with Google"].tap()
        delay(timeout: 10)

        // Trigger the interruption monitor with a swipeUp
        app.swipeUp()

        // Wait for the Google sign in webView
        XCTAssertTrue(app.webViews.element.waitForExistence(timeout: 10))

        // Check if we have an empty text field or an account to select from
        let emailTextField = app.webViews.element.textFields.element
        let loggedAccountLink = app.webViews.element.links[email]
        let emailTextFieldAvailable = emailTextField.waitForExistence(timeout: 10)

        if emailTextFieldAvailable {
            // Open the keyboard
            emailTextField.tap()

            // Disable 'Slide to type' if needed
            if app.buttons["Continue"].exists {
                app.buttons["Continue"].tap()
            }

            // Enter google email
            emailTextField.typeText(email)
            // Tap enter
            app.keyboards.buttons["return"].tap()

            // Wait for the password page to load
            delay(timeout: 2)
            let passwordTextField = app.webViews.element.secureTextFields.element
            _ = passwordTextField.waitForExistence(timeout: 10)
            passwordTextField.tap()
            delay(timeout: 1)
            // Enter password
            passwordTextField.typeText(password)
            // Tap enter
            app.keyboards.buttons["go"].tap()
        } else if loggedAccountLink.exists {
            loggedAccountLink.tap()
        } else {
            XCTAssertTrue(emailTextFieldAvailable || loggedAccountLink.exists, "At least one of these elements should be available.")
        }

        // Webview should be closed now, jus wait for the navigationBar to show up
        let navigationBarAvailable = app.navigationBars.element.waitForExistence(timeout: 10)

        XCTAssertTrue(navigationBarAvailable, "Navigation view didn't get displayed!")
    }

    // MARK: - Cancelled login
    func testImmediatelyCancelledLogin() {
        // Wait for the sign in system alert (Cancel / Continue)
        addUIInterruptionMonitor(withDescription: "Sign in") { alert -> Bool in
            if alert.buttons["Cancel"].exists {
                alert.buttons["Cancel"].tap()
                return true
            }
            return false
        }

        // Tap the sign in with google button
        app.buttons["Sign in with Google"].tap()
        delay(timeout: 10)

        // Trigger the interruption monitor with a swipeUp
        app.swipeUp()

        delay(timeout: 5)
        XCTAssert(
            app.staticTexts["You have cancelled the authorization request."].waitForExistence(timeout: 10),
            "The alert view should be displayed when the user cancels the SSO login flow."
        )
    }

}
