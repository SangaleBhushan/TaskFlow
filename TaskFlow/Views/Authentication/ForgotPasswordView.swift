//
//  ForgotPasswordView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI


struct ForgotPasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isSuccess = false

    private let repository = AuthRepository()

    var body: some View {

        NavigationStack {

            VStack(alignment: .leading,spacing: 24){

                Image(systemName: "lock.rotation")
                    .font(.system(size: 42))
                    .foregroundStyle(AppTheme.Colors.primary)

                Text("Reset your password")
                    .font(.system(size: 30,weight: .bold,design: .rounded))

                Text("Enter your email and we'll send you a link to reset your password.")
                .foregroundStyle(.secondary)

                AppTextField(
                    title: "Email",
                    placeholder: "Enter your email",
                    text: $email,
                    systemImage: "envelope"
                )

                if let message {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundStyle(isSuccess ? .green : .red)
                }

                Button {

                    Task {
                        await resetPassword()
                    }

                } label: {

                    HStack {

                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Send Reset Link")
                        }
                    }
                    .font(.system(size: 17,weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.Gradients.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Password Reset")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func resetPassword() async {

        guard !email.isEmpty else {

            message = "Please enter your email."
            isSuccess = false

            return
        }

        isLoading = true
        message = nil

        defer {
            isLoading = false
        }

        do {

            try await repository.sendPasswordReset(email: email)
            message = "Password reset link sent. Check your email."
            isSuccess = true

        } catch {
            message = FirebaseErrorMapper.message(for: error)
            isSuccess = false
        }
    }
}

#Preview {
    ForgotPasswordView()
}
