//
//  AppTextField.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct AppTextField: View {

    let title: String
    let placeholder: String
    @Binding var text: String
    let systemImage: String

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {

                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                TextField(placeholder,text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(title == "Email" ? .emailAddress : .default)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background( Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
