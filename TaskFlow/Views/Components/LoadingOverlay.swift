//
//  LoadingOverlay.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

struct LoadingOverlay: View {

    let title: String
    let message: String?

    var body: some View {

        ZStack {

            Color.black.opacity(0.25).ignoresSafeArea()

            VStack(spacing: 18) {

                ZStack {

                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 70, height: 70)

                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                }

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                if let message {

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 26)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.25),lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.2),radius: 30)
        }
        .contentShape(Rectangle())
        .allowsHitTesting(true)
    }
}
