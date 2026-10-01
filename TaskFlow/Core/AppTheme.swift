//
//  AppTheme.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI

enum AppTheme {

    enum Colors {
        static let primary = Color.indigo
        static let secondary = Color.purple
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
    }

    enum Gradients {
        static let primary = LinearGradient(
            colors: [
                Colors.primary,
                Colors.secondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum CornerRadius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}

