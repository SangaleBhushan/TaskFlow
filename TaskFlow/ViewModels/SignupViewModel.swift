//
//  SignupViewModel.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import Foundation
import Combine

@MainActor
final class SignupViewModel: ObservableObject {

    @Published var name = ""
    @Published var email = ""
    @Published var password = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }

    func signUp() async {
        guard validate() else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await repository.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            isAuthenticated = true

        } catch {
            errorMessage = FirebaseErrorMapper.message(for: error)
        }
    }

    private func validate() -> Bool {

        let trimmedName = name.trimmingCharacters( in: .whitespacesAndNewlines)

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            errorMessage = "Please enter your name."
            return false
        }

        if trimmedEmail.isEmpty {
            errorMessage = "Please enter your email."
            return false
        }

        if !isValidEmail(trimmedEmail) {
            errorMessage = "Please enter a valid email."
            return false
        }

        if password.isEmpty {
            errorMessage = "Please enter a password."
            return false
        }

        if password.count < 6 {
            errorMessage = "Password should be at least 6 characters."
            return false
        }

        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        return email.range( of: pattern,options: .regularExpression) != nil
    }
}
