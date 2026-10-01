//
//  PasswordField.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct PasswordField: View {

    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {

                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Group {
                    if isVisible {
                        TextField("Enter your password",text: $text)
                    } else {
                        SecureField("Enter your password",text: $text)
                    }
                }

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
