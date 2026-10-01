//
//  LoginView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = AuthViewModel()

    @State private var isPasswordVisible = false
    @State private var showForgotPassword = false

    var body: some View {

        NavigationStack {

            ZStack {

                AppTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading,spacing: 28){

                        Spacer(minLength: 35)

                        header
                        form

                        if let error = viewModel.errorMessage {
                            errorView(error)
                        }

                        loginButton
                        divider
                        signupSection

                        Spacer()
                    }.padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
        }.sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(alignment: .leading,spacing: 10){

            Text("Welcome back 👋")
                .font(.system(size: 34,weight: .bold,design: .rounded))

            Text("Stay organized.\nGet things done.")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Form

    private var form: some View {

        VStack(spacing: 18) {

            AppTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: $viewModel.email,
                systemImage: "envelope"
            )

            PasswordField(
                title: "Password",
                text: $viewModel.password,
                isVisible: $isPasswordVisible
            )

            HStack {

                Spacer()

                Button("Forgot Password?") {
                    showForgotPassword = true
                }.font(.system(size: 14,weight: .semibold))
                .foregroundStyle(AppTheme.Colors.primary)
            }
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {

        HStack(spacing: 10) {

            Image(systemName: "exclamationmark.circle.fill")

            Text(message)
                .font(.system(size: 14))

            Spacer()
        }
        .foregroundStyle(.red)
        .padding(14)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Login

    private var loginButton: some View {

        Button {

            Task {
                await viewModel.signIn()

                if viewModel.isAuthenticated {
                    router.showDashboard()
                }
            }

        } label: {

            HStack {

                if viewModel.isLoading {

                    ProgressView().tint(.white)

                } else {

                    Text("Sign In")
                    Image(systemName: "arrow.right")
                }
            }
            .font(.system(size: 17,weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.7 : 1)
    }

    // MARK: - Divider

    private var divider: some View {

        HStack {

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.quaternary)

            Text("OR")
                .font(.caption)
                .foregroundStyle(.secondary)

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.quaternary)
        }
    }

    // MARK: - Signup

    private var signupSection: some View {

        HStack {

            Spacer()

            Text("Don't have an account?")
                .foregroundStyle(.secondary)

            Button("Create account") {
                router.showSignup()
            }
            .fontWeight(.semibold)
            .foregroundStyle(AppTheme.Colors.primary)

            Spacer()
        }
    }
}
#Preview {
    LoginView()
}
//import SwiftUI
//
//struct LoginView: View {
//    @StateObject private var viewModel = AuthViewModel()
//    var body: some View {
//        Text("LOGIN SCREEN")
//            .font(.largeTitle)
//    }
//}
//
//#Preview {
//    LoginView()
//}
