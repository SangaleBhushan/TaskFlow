//
//  TaskCard.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 01/10/26.
//

import SwiftUI

struct TaskCard: View {

    let task: AppTask
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {

        HStack(alignment: .top, spacing: 14) {

            // MARK: Completion Button

            Button {
                withAnimation(.spring(response: 0.3)) {
                    onToggle()
                }
            } label: {

                ZStack {

                    Circle()
                        .fill(
                            task.isCompleted
                            ? Color.green.opacity(0.14)
                            : AppTheme.Colors.primary.opacity(0.10)
                        )
                        .frame(
                            width: 42,
                            height: 42
                        )

                    Image(
                        systemName:
                            task.isCompleted
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        task.isCompleted
                        ? .green
                        : AppTheme.Colors.primary
                    )
                    .symbolEffect(
                        .bounce,
                        value: task.isCompleted
                    )
                }
            }
            .buttonStyle(.plain)

            // MARK: Content

            VStack(
                alignment: .leading,
                spacing: 9
            ) {

                HStack(alignment: .top) {

                    Text(task.title)
                        .font(
                            .system(
                                size: 17,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .strikethrough(
                            task.isCompleted,
                            color: .secondary
                        )
                        .foregroundStyle(
                            task.isCompleted
                            ? .secondary
                            : .primary
                        )
                        .lineLimit(2)

                    Spacer()

                    Menu {

                        Button {
                            onEdit()
                        } label: {
                            Label(
                                "Edit",
                                systemImage: "pencil"
                            )
                        }

                        Button(
                            role: .destructive
                        ) {
                            onDelete()
                        } label: {
                            Label(
                                "Delete",
                                systemImage: "trash"
                            )
                        }

                    } label: {

                        Image(
                            systemName: "ellipsis"
                        )
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.secondary)
                        .frame(
                            width: 32,
                            height: 32
                        )
                        .background(
                            .secondary.opacity(0.08)
                        )
                        .clipShape(Circle())
                    }
                }

                // MARK: Description

                if !task.taskDescription.isEmpty {

                    Text(task.taskDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // MARK: Bottom Information

                HStack(spacing: 8) {

                    dateView

                    Spacer()

                    statusBadge
                }
            }
        }
        .padding(16)
        .background {

            RoundedRectangle(
                cornerRadius: 22
            )
            .fill(.ultraThinMaterial)
        }
        .overlay {

            RoundedRectangle(
                cornerRadius: 22
            )
            .stroke(
                borderColor,
                lineWidth: task.isOverdue ? 1.5 : 1
            )
        }
        .shadow(
            color: task.isOverdue
                ? .red.opacity(0.08)
                : .black.opacity(0.05),
            radius: 14,
            y: 6
        )
        .swipeActions(
            edge: .trailing,
            allowsFullSwipe: false
        ) {

            Button(
                role: .destructive
            ) {
                onDelete()
            } label: {

                Label(
                    "Delete",
                    systemImage: "trash"
                )
            }
        }
    }

    // MARK: - Date

    private var dateView: some View {

        HStack(spacing: 6) {

            Image(
                systemName:
                    task.isOverdue
                    ? "exclamationmark.circle.fill"
                    : "calendar"
            )

            VStack(
                alignment: .leading,
                spacing: 1
            ) {

                Text(
                    task.dueDate,
                    format: .dateTime
                        .month(.abbreviated)
                        .day()
                )
                .font(
                    .system(
                        size: 12,
                        weight: .semibold
                    )
                )

                Text(
                    task.dueDate,
                    format: .dateTime
                        .hour()
                        .minute()
                )
                .font(
                    .system(size: 11)
                )
            }
        }
        .foregroundStyle(
            task.isOverdue
            ? .red
            : .secondary
        )
    }

    // MARK: - Status

    private var statusBadge: some View {

        HStack(spacing: 6) {

            Circle()
                .fill(statusColor)
                .frame(
                    width: 7,
                    height: 7
                )

            Text(statusText)
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
        }
        .padding(
            .horizontal,
            10
        )
        .padding(
            .vertical,
            6
        )
        .background(
            statusColor.opacity(0.10)
        )
        .clipShape(Capsule())
    }

    private var statusText: String {

        if task.isOverdue {
            return "Overdue"
        }

        if task.isCompleted {
            return "Completed"
        }

        return "Pending"
    }

    private var statusColor: Color {

        if task.isOverdue {
            return .red
        }

        if task.isCompleted {
            return .green
        }

        return .orange
    }

    private var borderColor: Color {

        if task.isOverdue {
            return .red.opacity(0.35)
        }

        if task.isCompleted {
            return .green.opacity(0.15)
        }

        return .white.opacity(0.22)
    }
}
