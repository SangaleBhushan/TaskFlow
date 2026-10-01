//
//  DashboardStatCard.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 01/10/26.
//

import SwiftUI

struct DashboardStatCard: View {

    let title: String
    let value: Int
    let icon: String
    let tint: Color

    var body: some View {

        VStack(alignment: .leading,spacing: 14){

            HStack {

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(tint)

                Spacer()
            }

            Text("\(value)")
                .font(
                    .system(
                        size: 28,
                        weight: .bold,
                        design: .rounded
                    )
                )

            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    .white.opacity(0.25),
                    lineWidth: 1
                )
        }
    }
}
