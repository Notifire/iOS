//
//  UnprotectedAPIIntegrationTests.swift
//  NotifireTests
//
//  Created by David Bielik on 12/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import XCTest
@testable import Notifire

// swiftlint:disable type_name
class _UnprotectedAPIIntegrationTests: XCTestCase {
// swiftlint:enable type_name

     // MARK: - Properties
       var apiManager: NotifireAPIManager {
           return NotifireAPIManager()
       }

    func commonCompletion<T>(expectation: XCTestExpectation) -> NotifireAPIBaseManager.Callback<T> {
        return { (response) in
            switch response {
            case .error(let error):
                print("ERROR \(expectation.description) \(error)")
            case .success:
                // Don't read the body, any response is fine.
                expectation.fulfill()
            }
        }
    }

    // MARK: - CommonCompletion
    /// Test if the commonCompletion function fulfills the expectation on successful APIManager result
    func testCommonCompletionSuccess() {
        let successfulExpectation = expectation(description: "Completion should fulfill this expectation")

        let completion: NotifireAPIBaseManager.Callback<String> = commonCompletion(expectation: successfulExpectation)
        completion(.success(""))

        wait(for: [successfulExpectation], timeout: 0.5)
    }

    /// Test if the commonCompletion function covers all NotifireAPIError cases
    func testCommonCompletionErrors() {
        var failedExpectations = [XCTestExpectation]()
        let errors: [NotifireAPIError] = [
            .invalidResponseBody(EmptyRequestBody.self, ""),
            .invalidStatusCode(400, nil),
            .responseDataIsNil,
            .unknown,
            .urlResponseNotCreated,
            .urlSession(error: NSError(domain: NSURLErrorDomain, code: 1000, userInfo: nil))
        ]

        for apiError in errors {
            let failedExpectation = expectation(description: "Completion should not fulfill this expectation. Error: \(apiError.description)")
            failedExpectation.isInverted = true

            let completion: NotifireAPIBaseManager.Callback<String> = commonCompletion(expectation: failedExpectation)
            completion(.error(apiError))

            failedExpectations.append(failedExpectation)
        }

        wait(for: failedExpectations, timeout: 0.5)
    }

    // MARK: - Endpoints
    private let timeout: TimeInterval = 5
    // MARK: API Data
    private let email = "test@testicek.testicek"
    private let password = "123456789"
    private let confirmAccountToken = "ZXlKMGVYQWlPaUpLVjFRaUxDSmhiR2NpT2lKSVV6STFOaUo5LmV5SnBjM01pT2lKT2IzUnBabWx5WlNJc0ltRmpkR2x2YmlJNkltTnZibVpwY20xZlpXMWhhV3dpTENKMWMyVnlYMmxrSWpveExDSjFjMlZ5WDNObFkzSmxkQ0k2SW1ZMk9UUXhaR1poWWpoaE1qRTVPREV4WTJVd1pUSXhObVF4WXprNFpHWTFabVkzWVRobU9EazJaVEJrWVdFM05UWTNabVprWldOaVl6RmpZV1UwWlRNMU1EQmlNVFZoTmpoaE5qWm1OVGxrTVdRNE56RTNOamRrTmpka01XUTJNall5WkRJd01XWTJZamc0Tm1SalpHUTVOek5qWkdRNFpqTTNOVGM1T1dJNUlpd2lhV0YwSWpveE5UazVPVFV4TVRRNExDSmxlSEFpT2pFMk1EQXhNak01TkRoOS5XQllLMWhLaGtSSTBIeEk0Y1lKbUZWTHNRS1BGSkZ3cVRPbTF3RFJVU0M0"

    // MARK: NotifireAPIEndpoint
    /// Tests access to each unprotected endpoint. If any of the endpoints urls are not matching those on a remote server, this test will fail.
    func testUnprotectedEndpointsReachability() {
        // Create endpoint array which will contain all endpoints as strings
        var endpoints = NotifireAPIEndpoint.allCases.map { $0.rawValue }
        let providers: [SSOAuthenticationProvider] = [.google, .apple]
        // add SSO provider endpoints
        endpoints += providers.map {  NotifireAPIEndpoint.login(ssoProvider: $0) }
        var expectations = [XCTestExpectation]()

        for endpoint in endpoints {
            let endpointExpectation = expectation(description: "\(endpoint.description) should return 400 or 405")
            // create a request for each endpoint
            let request = apiManager.createAPIRequest(endpoint: endpoint, method: .get, body: nil as EmptyRequestBody?)
            let requestContext = URLRequestContext(responseBodyType: EmptyRequestBody.self, apiRequest: request)
            // manual perform
            apiManager.perform(requestContext: requestContext) { result in
                switch result {
                case .error(.invalidStatusCode(400, _)), .error(.invalidStatusCode(405, _)):
                    // Allow 400 in case the request method is GET
                    // Allow 405 in case the request method isn't GET
                    endpointExpectation.fulfill()
                default:
                    break
                }
            }
            expectations.append(endpointExpectation)
        }

        wait(for: expectations, timeout: 20)
    }

    // MARK: Register
    func testRegister() {
        let requestSuccessExpectation = expectation(description: "Register request should return 200.")

        apiManager.register(email: email, password: password, completion: commonCompletion(expectation: requestSuccessExpectation))

        wait(for: [requestSuccessExpectation], timeout: timeout)
    }

    // MARK: Send confirm email
    func testResendConfirmEmail() {
        let requestSuccessExpectation = expectation(description: "Resend confirm email request should return 200.")

        apiManager.sendConfirmEmail(to: email, completion: commonCompletion(expectation: requestSuccessExpectation))

        wait(for: [requestSuccessExpectation], timeout: timeout)
    }

    // MARK: Check email availability
    func testCheckValidity() {
        let requestSuccessExpectation = expectation(description: "Check validity request should return 200.")

        apiManager.checkValidity(option: .email, input: email, completion: commonCompletion(expectation: requestSuccessExpectation))

        wait(for: [requestSuccessExpectation], timeout: timeout)
    }

    // MARK: Email login
    func testEmailLogin() {
        let requestSuccessExpectation = expectation(description: "Email login request should return 200.")

        apiManager.login(email: email, password: password, completion: commonCompletion(expectation: requestSuccessExpectation))

        wait(for: [requestSuccessExpectation], timeout: timeout)
    }

    // MARK: Send reset password email
    func testSendResetPasswordEmail() {
        let requestSuccessExpectation = expectation(description: "Send reset password request should return 200.")

        apiManager.sendResetPassword(email: email, completion: commonCompletion(expectation: requestSuccessExpectation))

        wait(for: [requestSuccessExpectation], timeout: timeout)
    }
}
