//
//  AuthViewModelTests.swift
//  TaskFlowTests
//
//  Created by Bhushan Sangale on 01/10/26.
//

import XCTest
import FirebaseAuth
@testable import TaskFlow

@MainActor
final class AuthViewModelTests: XCTestCase {

    func testEmptyEmailShowsValidationError() async {
        let repository = MockAuthRepository()
        let viewModel = AuthViewModel(repository: repository)

        viewModel.email = ""
        viewModel.password = "Password123"

        await viewModel.signIn()

        XCTAssertEqual(
            viewModel.errorMessage,
            "Please enter your email."
        )

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(repository.signInCalled)
    }

    func testInvalidEmailShowsValidationError() async {
        let repository = MockAuthRepository()
        let viewModel = AuthViewModel(repository: repository)

        viewModel.email = "invalid-email"
        viewModel.password = "Password123"

        await viewModel.signIn()

        XCTAssertEqual(
            viewModel.errorMessage,
            "Please enter a valid email."
        )

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(repository.signInCalled)
    }

    func testEmptyPasswordShowsValidationError() async {
        let repository = MockAuthRepository()
        let viewModel = AuthViewModel(repository: repository)

        viewModel.email = "test@example.com"
        viewModel.password = ""

        await viewModel.signIn()

        XCTAssertEqual(
            viewModel.errorMessage,
            "Please enter your password."
        )

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(repository.signInCalled)
    }

    func testSuccessfulSignInAuthenticatesUser() async {
        let repository = MockAuthRepository()
        let viewModel = AuthViewModel(repository: repository)

        viewModel.email = "test@example.com"
        viewModel.password = "Password123"

        await viewModel.signIn()

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(repository.signInCalled)
        XCTAssertEqual(repository.receivedEmail, "test@example.com")
        XCTAssertEqual(repository.receivedPassword, "Password123")
    }

    func testEmailIsTrimmedBeforeSignIn() async {
        let repository = MockAuthRepository()
        let viewModel = AuthViewModel(repository: repository)

        viewModel.email = "  test@example.com  "
        viewModel.password = "Password123"

        await viewModel.signIn()

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(
            repository.receivedEmail,
            "test@example.com"
        )
    }

    func testRepositoryErrorIsDisplayed() async {
        let repository = MockAuthRepository()
        repository.shouldFail = true

        let viewModel = AuthViewModel(repository: repository)

        viewModel.email = "test@example.com"
        viewModel.password = "Password123"

        await viewModel.signIn()

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}

// MARK: - Mock Repository

private final class MockAuthRepository: AuthRepositoryProtocol {

    var signInCalled = false
    var shouldFail = false

    var receivedEmail: String?
    var receivedPassword: String?

    func signIn(email: String,password: String) async throws {

        signInCalled = true
        receivedEmail = email
        receivedPassword = password

        if shouldFail {
            throw MockAuthError.authenticationFailed
        }
    }

    func signUp(email: String,password: String) async throws {
        if shouldFail {
            throw MockAuthError.authenticationFailed
        }
    }

    func sendPasswordReset(email: String) async throws {
        if shouldFail {
            throw MockAuthError.authenticationFailed
        }
    }

    func signOut() throws {
        if shouldFail {
            throw MockAuthError.authenticationFailed
        }
    }

    func currentUser() -> User? {
        nil
    }
}

private enum MockAuthError: Error {
    case authenticationFailed
}
