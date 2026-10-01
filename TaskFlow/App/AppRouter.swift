//
//  AppRouter.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {

    enum Screen {
        case launch
        case login
        case signup
        case dashboard
    }

    @Published var screen: Screen = .launch

    func showLogin() {
        withAnimation(.easeInOut(duration: 0.35)) {
            screen = .login
        }
    }

    func showSignup() {
        withAnimation(.easeInOut(duration: 0.35)) {
            screen = .signup
        }
    }

    func showDashboard() {
        withAnimation(.easeInOut(duration: 0.35)) {
            screen = .dashboard
        }
    }

    func showLaunch() {
        withAnimation(.easeInOut(duration: 0.35)) {
            screen = .launch
        }
    }
}
