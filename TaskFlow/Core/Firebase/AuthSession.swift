//
//  AuthSession.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthSession: ObservableObject {

    @Published private(set) var user: User?
    @Published private(set) var isLoading = true

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var hasStarted = false

    var isAuthenticated: Bool {
        user != nil
    }

    func start() {
        
        guard !hasStarted else {
            return
        }
        hasStarted = true
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            
            Task { @MainActor in
                self?.user = user
                self?.isLoading = false
            }
        }
    }

    func stop() {

        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }

        authStateHandle = nil
        hasStarted = false
        user = nil
        isLoading = true
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
