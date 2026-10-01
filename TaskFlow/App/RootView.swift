//
//  RootView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var authSession: AuthSession

    @StateObject private var networkStatus = NetworkStatus()

    var body: some View {

        ZStack(alignment: .top) {

            Group {
                switch router.screen {

                case .launch:
                    LaunchView()

                case .login:
                    LoginView()

                case .signup:
                    SignupView()

                case .dashboard:
                    DashboardView()
                }
            }

            if !networkStatus.isConnected {
                OfflineBanner(isConnected: networkStatus.isConnected)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
            }
        }
        .animation(.spring(response: 0.55,dampingFraction: 0.82),value: networkStatus.isConnected )
        .task {
            authSession.start()
        }
    }
}
