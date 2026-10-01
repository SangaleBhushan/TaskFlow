//
//  LaunchView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct LaunchView: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var authSession: AuthSession

    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showSubtitle = false

    var body: some View {

        ZStack {

            AppTheme.Gradients.primary
                .ignoresSafeArea()

            VStack(spacing: 20) {

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 130, height: 130)

                    Circle()
                        .fill(.white.opacity(0.10))
                        .frame(width: 110, height: 110)

                    Image(systemName: "checkmark")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(.white)
                }.scaleEffect(showLogo ? 1 : 0.6)
                 .opacity(showLogo ? 1 : 0)

                Text("TaskFlow")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 15)

                Text("Plan. Do. Done.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 10)
            }
        }
        .task {
            await startLaunch()
        }
    }

    

    private func startLaunch() async {

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showLogo = true
        }

        try? await Task.sleep(for: .milliseconds(300))

        withAnimation(.easeOut(duration: 0.5)) {
            showTitle = true
        }

        try? await Task.sleep(for: .milliseconds(700))

        while authSession.isLoading {
            try? await Task.sleep(for: .milliseconds(100))
        }
        if authSession.isAuthenticated {
            router.showDashboard()
        } else {
            router.showLogin()
        }
    }
}

#Preview {
    LaunchView()
        .environmentObject(AppRouter())
}
