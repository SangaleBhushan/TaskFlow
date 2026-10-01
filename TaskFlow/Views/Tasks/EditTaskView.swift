//
//  EditTaskView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 01/10/26.
//

import SwiftUI

struct EditTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    let task: AppTask

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var showDatePicker = false
    @FocusState private var focusedField: Field?

    enum Field {
        case title
        case description
    }

    init(task: AppTask,viewModel: TaskViewModel){

        self.task = task
        self.viewModel = viewModel

        _title = State(initialValue: task.title)
        _description = State(initialValue: task.taskDescription)
        _dueDate = State(initialValue: task.dueDate)
    }

    private var isFormValid: Bool {

        !title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        &&
        dueDate >= Date()
    }

    var body: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.10),
                        Color.purple.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {

                        Text("Update your task")
                            .font(
                                .system(
                                    size: 30,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )

                        Text("Make any changes you need.")
                            .foregroundStyle(.secondary)

                        AppTextField(
                            title: "Title",
                            placeholder: "Task title",
                            text: $title,
                            systemImage: "checkmark.circle"
                        )

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            Text("DESCRIPTION")
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    .secondary
                                )

                            TextEditor(
                                text: $description
                            )
                            .focused(
                                $focusedField,
                                equals: .description
                            )
                            .frame(minHeight: 130)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(
                                .ultraThinMaterial
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                            )
                        }

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            Text("DUE DATE")
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    .secondary
                                )

                            DatePicker(
                                "Due date",
                                selection: $dueDate,
                                in: Date()...,
                                displayedComponents: [
                                    .date,
                                    .hourAndMinute
                                ]
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(
                                .ultraThinMaterial
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20
                                )
                            )
                        }

                        if let error =
                            viewModel.errorMessage {

                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .padding(14)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .background(
                                    Color.red.opacity(0.08)
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 14
                                    )
                                )
                        }

                        Button {

                            focusedField = nil

                            Task {

                                var updatedTask = task

                                updatedTask.title =
                                    title.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )

                                updatedTask.taskDescription =
                                    description.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )

                                updatedTask.dueDate =
                                    dueDate

                                if await viewModel.updateTask(
                                    updatedTask
                                ) {

                                    dismiss()
                                }
                            }

                        } label: {

                            Text("Save Changes")
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(.white)
                                .frame(
                                    maxWidth: .infinity
                                )
                                .frame(height: 56)
                                .background(
                                    isFormValid
                                    ? AnyShapeStyle(
                                        AppTheme.Gradients.primary
                                    )
                                    : AnyShapeStyle(
                                        Color.secondary.opacity(0.25)
                                    )
                                )
                                .clipShape(RoundedRectangle( cornerRadius: 17))
                        }
                        .disabled(!isFormValid ||  viewModel.isSaving)
                    }
                    .padding(20)
                }

                if viewModel.isSaving {
                    LoadingOverlay(title: "Updating task...",message: "Saving your changes")
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
        }.interactiveDismissDisabled(viewModel.isSaving)
    }
}
