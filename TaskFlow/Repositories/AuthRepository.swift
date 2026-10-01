//
//  AuthRepository.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import Foundation
import FirebaseAuth

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func currentUser() -> User?
}

final class AuthRepository: AuthRepositoryProtocol {

    private var auth: Auth {
        Auth.auth()
    }

    func signIn(email: String,password: String) async throws {

        try await auth.signIn(withEmail: email,password: password)
    }

    func signUp(email: String,password: String) async throws {

        try await auth.createUser(withEmail: email,password: password)
    }

    func sendPasswordReset(email: String) async throws {

        try await auth.sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func currentUser() -> User? {
        auth.currentUser
    }
}
