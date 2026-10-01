//
//  SignupView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct SignupView: View {

    @EnvironmentObject private var router: AppRouter

    @StateObject private var viewModel = SignupViewModel()

    @State private var isPasswordVisible = false

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 28) {

                header
                form

                if let error = viewModel.errorMessage {
                    errorView(error)
                }

                signupButton

                Spacer(minLength: 20)
            }
            .padding(24)
        }
        .background(AppTheme.Colors.background)
        .navigationBarBackButtonHidden()
    }

    // MARK: - Header

    private var header: some View {

        VStack(alignment: .leading, spacing: 10) {

            Button {
                router.showLogin()
            } label: {

                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            .foregroundStyle(AppTheme.Colors.primary)

            Text("Create account")
                .font(.system(size: 34,weight: .bold,design: .rounded))

            Text("Start organizing your day.")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Form

    private var form: some View {

        VStack(spacing: 18) {

            AppTextField(
                title: "Name",
                placeholder: "Your name",
                text: $viewModel.name,
                systemImage: "person"
            )

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

    // MARK: - Signup Button

    private var signupButton: some View {

        Button {

            Task {
                await viewModel.signUp()

                if viewModel.isAuthenticated {
                    router.showLogin()
                }
            }

        } label: {

            HStack {

                if viewModel.isLoading {

                    ProgressView().tint(.white)

                } else {

                    Text("Create Account")
                    Image(systemName: "arrow.right")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.7 : 1)
    }
}

#Preview {
    SignupView()
        .environmentObject(AppRouter())
}
