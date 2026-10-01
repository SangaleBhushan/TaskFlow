//
//  OfflineBanner.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 01/10/26.
//

import SwiftUI

struct OfflineBanner: View {

    let isConnected: Bool

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 38, height: 38)

                Image(systemName: "wifi.slash")
                    .font(.system(size: 15, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("You're offline")
                    .font(.system(size: 14, weight: .bold))

                Text("Changes will sync when connection returns.")
                    .font(.system(size: 11, weight: .medium))
                    .opacity(0.82)
            }

            Spacer()

            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 15, weight: .semibold))
                .opacity(0.75)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .orange.opacity(0.85),
                                    .red.opacity(0.65)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            .white.opacity(0.28),
                            lineWidth: 1
                        )
                }
        }
        .shadow(
            color: .black.opacity(0.18),
            radius: 20,
            y: 8
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
