//
//  AppVersionManagerTests.swift
//  NotifireTests
//
//  Created by David Bielik on 12/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest
@testable import Notifire

class AppVersionManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Util
    func createManager(apiManager: NotifireAPIManager = NotifireAPIFactory.createAPIManager(), currentVersion: String = "1.0.0") -> AppVersionManager {
        return AppVersionManager(currentVersion: currentVersion)
    }

    let response = AppVersionResponse(forceUpdate: true, latestVersion: "1.0.0")

    // MARK: - State Tests
    /// Test whether the initial state of AppVersionManager is correct.
    func testInitialState() {
        // Given
        let manager: AppVersionManager
        // When
        manager = createManager()
        // Then
        guard case .initial = manager.state else {
            XCTFail("State should be .initial")
            return
        }
    }

    /// Test if `canFetchAppVersionData` returns `true` if `state == .initial`.
    func testCanFetchAppVersionDataInitial() {
        // Given
        let manager = createManager()
        // When
        manager.state = .initial
        // Then
        XCTAssert(manager.canFetchAppVersionData)
    }

    /// Test if `canFetchAppVersionData` returns `false` if `state == .fetching`.
    func testCanFetchAppVersionDataFetching() {
        // Given
        let manager = createManager()
        // When
        manager.state = .fetching
        // Then
        XCTAssertFalse(manager.canFetchAppVersionData)
    }

    /// Test if `canFetchAppVersionData` returns `false` if `state == .checked`.
    func testCanFetchAppVersionDataInitialChecked() {
        // Given
        let manager = createManager()
        // When
        manager.state = .checked(appVersionData: AppVersionData(appVersionResponse: AppVersionResponse(forceUpdate: false, latestVersion: "")))
        // Then
        XCTAssertFalse(manager.canFetchAppVersionData)
    }

    /// Test if fetchVersionData continues without throwing an error when canFetchAppVersionData is true
    func testFetchVersionDataCanFetchNoThrow() {
        // Given
        let manager = createManager()
        // When
        XCTAssert(manager.canFetchAppVersionData)
        // Then
        XCTAssertNoThrow(try manager.fetchAppVersionData())
    }

    /// Test if fetchVersionData throws an error when canFetchAppVersionData is false
    func testFetchVersionDataCanFetchThrows() {
        // Given
        let manager = createManager()
        manager.state = .fetching
        // When
        XCTAssertFalse(manager.canFetchAppVersionData)
        // Then
        XCTAssertThrowsError(try manager.fetchAppVersionData())
    }

    // MARK: - Fetch App Version Data Tests
    /// Test if AppVersionManager changes state to fetching after starting a fetchAppVersionData request.
    func testFetchAppVersionDataImmediateStateChange() {
        // Given
        let manager = createManager()
        // When
        XCTAssertNoThrow(try manager.fetchAppVersionData())
        // Then
        guard case .fetching = manager.state else {
            XCTFail("State should be .fetching")
            return
        }
    }

    /// Test if AppVersionManager changes state to initial after finishing a fetchAppVersionData request with an error.
    func testFetchAppVersionDataStateChangeToInitialAfterError() {
        // Given
        let stateExpectation = expectation(description: "State should be .initial")
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnError(.unknown))
        apiManager.mockCompletion = {
            stateExpectation.fulfill()
        }
        let manager = createManager(apiManager: apiManager)
        // When
        XCTAssertNoThrow(try manager.fetchAppVersionData())
        // Then
        wait(for: [stateExpectation], timeout: 5)
        guard case .initial = manager.state else {
            XCTFail("State should be .initial")
            return
        }
    }

    /// Test if AppVersionManager changes state to checked after finishing a fetchAppVersionData request with an error.
    func testFetchAppVersionDataStateChangeToCheckedAfterSuccess() {
        // Given
        let stateExpectation = expectation(description: "State should be .checked with \(response)")
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnSuccess(response))
        apiManager.mockCompletion = {
            stateExpectation.fulfill()
        }
        let manager = createManager(apiManager: apiManager)
        // When
        XCTAssertNoThrow(try manager.fetchAppVersionData())
        // Then
        wait(for: [stateExpectation], timeout: 5)
        guard case .checked(let receivedData) = manager.state else {
            XCTFail("State should be .initial")
            return
        }
        XCTAssertEqual(receivedData.appVersionResponse, response)
    }

    /// Test if AppVersionManager posts a Notification.Name.didReceiveAppVersionCheck notification after successful response form the server.
    func testFetchAppVersionDataSuccessNotification() {
        // Given
        let notificationExpectation = expectation(description: "Notification.Name.didReceiveAppVersionCheck should be received")
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnSuccess(response))
        let manager = createManager(apiManager: apiManager)
        let observer = NotificationObserver(notificationName: .didReceiveAppVersionCheck) { _ in
            notificationExpectation.fulfill()
        }
        // When
        XCTAssertNoThrow(try manager.fetchAppVersionData())
        // Then
        wait(for: [notificationExpectation], timeout: 10)

        // Print notification names to get around unused param warning
        // and deallocation of observer
        print(observer.notificationNames)
    }

    func testFetchAppVersionDataRetry() {
        // Given
        var numberOfCompletions = 0
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnError(.unknown))
        let manager = createManager(apiManager: apiManager)
        let retryExpectation = expectation(description: "The mock completion should be called at least twice")
        apiManager.mockCompletion = {
            numberOfCompletions += 1
            if numberOfCompletions >= 2 {
                retryExpectation.fulfill()
            }
        }
        // When
        XCTAssertNoThrow(try manager.fetchAppVersionData())
        // Then
        wait(for: [retryExpectation], timeout: 20)
    }

    // MARK: - DecideIfUserShouldUpdate Tests
    func commonDecideIfUserShouldUpdate(currentVersion: String, latestVersion: String, forceUpdate: Bool, appUpdateReminderEnabled: Bool = true, expectedAction: AppVersionManager.AppVersionUpdateAction) {
        // Given
        let appVersionData = AppVersionData(
            appVersionResponse: AppVersionResponse(forceUpdate: forceUpdate, latestVersion: latestVersion)
        )
        let manager = createManager(currentVersion: currentVersion)
        let session = UserSession(refreshToken: "", providerData: AuthenticationProviderData(provider: .email, email: "", userID: ""))
        session.settings.appUpdateReminderEnabled = appUpdateReminderEnabled
        // When
        let updateAction = manager.decideIfUserShouldUpdate(versionData: appVersionData, userSession: session)
        // Then
        XCTAssertEqual(updateAction, expectedAction)
    }

    /// Test whether `.updateRequired` is returned when the server requests it.
    func testDecideUserUpdateRequired() {
        // Given
        let version = "1.0.0"
        commonDecideIfUserShouldUpdate(
            currentVersion: version,
            latestVersion: version,
            forceUpdate: true,
            expectedAction: .updateRequired
        )
    }

    /// Test whether `.userHasHiddenAlerts` is returned when the user has hidden update alerts and update is not forced.
    func testDecideUserUpdateAlertsHidden() {
        commonDecideIfUserShouldUpdate(
            currentVersion: "1.0.0",
            latestVersion: "1.2.0",
            forceUpdate: false,
            appUpdateReminderEnabled: false,
            expectedAction: .userHasHiddenAlerts
        )
    }

    /// Test whether `.updateRequired` is returned when the user has hidden update alerts and update is forced.
    func testDecideUserUpdateAlertsHiddenUpdateRequired() {
        commonDecideIfUserShouldUpdate(
            currentVersion: "1.0.0",
            latestVersion: "1.2.0",
            forceUpdate: true,
            appUpdateReminderEnabled: false,
            expectedAction: .updateRequired
        )
    }

    /// Test whether `.updateAvailable` is returned when a higher minor version is returned from server.
    func testDecideUserUpdateAvailable() {
        commonDecideIfUserShouldUpdate(
            currentVersion: "1.0.0",
            latestVersion: "1.2.0",
            forceUpdate: false,
            appUpdateReminderEnabled: true,
            expectedAction: .updateAvailable
        )
    }

    /// Test whether `.updateAvailable` is returned when a higher minor version is returned from server.
    func testDecideUserUpdateLatestVersion() {
        let version = "1.2.0"
        commonDecideIfUserShouldUpdate(
            currentVersion: version,
            latestVersion: version,
            forceUpdate: false,
            appUpdateReminderEnabled: true,
            expectedAction: .latestVersion
        )
    }
}
