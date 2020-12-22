//
//  NotifireAPIManagerFetchMockTests.swift
//  NotifireTests
//
//  Created by David Bielik on 13/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest
@testable import Notifire

// MARK: - NotifireAPIManagerFetchMock
class NotifireAPIManagerFetchMock: NotifireAPIManager, NotifireAPIManagerMocking {

    enum MockType {
        case returnError(NotifireAPIError)
        case returnSuccess(AppVersionResponse)
    }

    let mockType: MockType
    var mockCompletion: (() -> Void)?

    init(apiHandler: APIHandler = URLSession.custom, mockType: MockType) {
        self.mockType = mockType
        super.init(apiHandler: apiHandler)
    }

    override func checkAppVersion(currentVersion: String = Config.appVersion, completion: @escaping Callback<AppVersionResponse>) {
        let customCompletion: Callback<AppVersionResponse> = { [weak self] result in
            completion(result)
            self?.mockCompletion?()
        }
        switch mockType {
        case .returnError(let error):
            returnErrorResponseAfter(error: error, completion: customCompletion)
        case .returnSuccess(let response):
            returnSuccessAfter(completion: customCompletion, response: response)
        }
    }
}

// MARK: - Tests
class NotifireAPIManagerFetchMockTests: XCTestCase {

    /// Test if `NotifireAPIManagerFetchMock` returns error when requested.
    func testNotifireAPIManagerFetchMockReturnError() {
        // Given
        let error = NotifireAPIError.unknown
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnError(error))
        let version = "1.0.0"
        // When
        apiManager.checkAppVersion(currentVersion: version) { result in
            // Then
            switch result {
            case .error(let returnedError):
                XCTAssertEqual(returnedError, error)
            case .success:
                XCTFail("Response should have been an error.")
            }
        }
    }

    /// Test if `NotifireAPIManagerFetchMock` returns successful response when requested.
    func testNotifireAPIManagerFetchMockReturnSuccess() {
        // Given
        let version = "1.0.0"
        let response = AppVersionResponse(forceUpdate: false, latestVersion: version)
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnSuccess(response))
        // When
        apiManager.checkAppVersion(currentVersion: version) { result in
            // Then
            switch result {
            case .error(let error):
                XCTFail("Respons should have been a success, not \(error.localizedDescription)")
            case .success(let returnedResponse):
                XCTAssertEqual(returnedResponse, response)
            }
        }
    }

    /// Test whether mockCompletion gets called.
    func testNotifireAPIManagerFetchMockCompletionCalled() {
        // Given
        let mockCompletionExpectation = expectation(description: "Mock completion should get called.")
        let apiManager = NotifireAPIManagerFetchMock(mockType: .returnSuccess(AppVersionResponse(forceUpdate: true, latestVersion: "1.0.0")))
        apiManager.mockCompletion = {
            mockCompletionExpectation.fulfill()
        }
        // When
        apiManager.checkAppVersion { _ in }
        // Then
        wait(for: [mockCompletionExpectation], timeout: 5)
    }
}
