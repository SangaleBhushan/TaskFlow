//
//  AuthViewModel.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
        self.isAuthenticated = false
    }
    
    func signIn() async {

        guard validateLogin() else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {isLoading = false}

        do {

            try await repository.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines),password: password)
            isAuthenticated = true

        } catch {
            errorMessage = FirebaseErrorMapper.message(for: error)
        }
    }

    private func validateLogin() -> Bool {

        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            errorMessage = "Please enter your email."
            return false
        }

        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email."
            return false
        }

        if password.isEmpty {
            errorMessage = "Please enter your password."
            return false
        }

        return true
    }

    private func isValidEmail(_ email: String) -> Bool {

        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
