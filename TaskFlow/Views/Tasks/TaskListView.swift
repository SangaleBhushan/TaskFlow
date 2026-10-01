//
//  TaskListView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 01/10/26.
//

import SwiftUI

struct TaskListView: View {

    
    @ObservedObject var viewModel: TaskViewModel
    @State private var showAddTask = false
    @State private var selectedTask: AppTask?
    @State private var taskToDelete: AppTask?
    var body: some View {

        ZStack {

            background

            VStack(spacing: 0) {

                header
                searchBar
                filterBar
                content
            }
        }
        .task {
            viewModel.startListening()
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .sheet(item: $selectedTask) { task in
            EditTaskView(task: task,viewModel: viewModel)
        }
        .confirmationDialog("Delete Task?",
            isPresented: Binding(
                get: {
                    taskToDelete != nil
                },
                set: {
                    if !$0 {
                        taskToDelete = nil
                    }
                }
            ),
            titleVisibility: .visible
        ){

            Button("Delete",role: .destructive) {

                if let task = taskToDelete {
                    Task {
                        await viewModel.deleteTask(task)
                    }
                }
                taskToDelete = nil
            }

            Button("Cancel", role: .cancel) {
                taskToDelete = nil
            }

        } message: {
            Text( "This action cannot be undone.")
        }
    }

    // MARK: - Background

    private var background: some View {

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
    }

    // MARK: - Header

    private var header: some View {

        HStack(alignment: .center) {

            VStack(alignment: .leading,spacing: 5){

                Text("TaskFlow")
                    .font(.system(size: 14,weight: .semibold,design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary )

                HStack(spacing: 8) {

                    Text("My Tasks")
                        .font(
                            .system(
                                size: 32,
                                weight: .bold,
                                design: .rounded
                            )
                        )

                    if viewModel.totalCount > 0 {

                        Text("\(viewModel.totalCount)")
                            .font(
                                .system(
                                    size: 12,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                AppTheme.Colors.primary
                            )
                            .padding(
                                .horizontal,
                                9
                            )
                            .padding(
                                .vertical,
                                5
                            )
                            .background(
                                AppTheme.Colors.primary
                                    .opacity(0.10)
                            )
                            .clipShape(Capsule())
                    }
                }

                if viewModel.pendingCount > 0 {

                    Text(
                        "\(viewModel.pendingCount) task\(viewModel.pendingCount == 1 ? "" : "s") waiting for you"
                    )
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                } else if viewModel.totalCount > 0 {

                    Text("Everything is completed 🎉")
                        .font(.system(size: 13))
                        .foregroundStyle(.green)

                } else {

                    Text("Let's get something done.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {

                showAddTask = true

            } label: {

                Image(systemName: "plus")
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        width: 46,
                        height: 46
                    )
                    .background(
                        AppTheme.Gradients.primary
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 15
                        )
                    )
                    .shadow(
                        color: .indigo.opacity(0.20),
                        radius: 10,
                        y: 5
                    )
            }
            .accessibilityLabel("Add task")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    // MARK: - Search

    private var searchBar: some View {

        HStack(spacing: 12) {

            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(
                "Search tasks...",
                text: $viewModel.searchText
            )

            if !viewModel.searchText.isEmpty {

                Button {

                    viewModel.searchText = ""

                } label: {

                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: 16
            )
            .stroke(
                .white.opacity(0.25),
                lineWidth: 1
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Filters

    private var filterBar: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: 10) {

                ForEach(
                    TaskFilter.allCases
                ) { filter in

                    Button {

                        withAnimation(
                            .easeInOut(duration: 0.2)
                        ) {
                            viewModel.selectedFilter =
                                filter
                        }

                    } label: {

                        HStack(spacing: 6) {

                            Image(
                                systemName: filter.icon
                            )

                            Text(filter.title)
                        }
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            viewModel.selectedFilter == filter
                            ? .white
                            : .primary
                        )
                        .padding(
                            .horizontal,
                            14
                        )
                        .frame(height: 38)
                        .background {

                            if viewModel.selectedFilter == filter {
                                Capsule()
                                    .fill(
                                        AppTheme.Gradients.primary
                                    )
                            } else {
                                Capsule()
                                    .fill(
                                        .ultraThinMaterial
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {

        if viewModel.isLoading {

            loadingView

        } else if let error = viewModel.errorMessage,
                  viewModel.tasks.isEmpty {

            errorState(error)

        } else if viewModel.filteredTasks.isEmpty {

            emptyState

        } else {

            taskList
        }
    }

    // MARK: - Loading

    private var loadingView: some View {

        VStack(spacing: 18) {

            ProgressView()
                .controlSize(.large)
                .tint(
                    AppTheme.Colors.primary
                )

            Text("Loading your tasks...")
                .font(.headline)

            Text("Getting everything ready")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Empty

    private var emptyState: some View {

        VStack(spacing: 18) {

            ZStack {

                Circle()
                    .fill(
                        AppTheme.Colors.primary
                            .opacity(0.10)
                    )
                    .frame(
                        width: 100,
                        height: 100
                    )

                Image(
                    systemName: "checklist"
                )
                .font(.system(size: 42))
                .foregroundStyle(
                    AppTheme.Colors.primary
                )
            }

            Text(
                viewModel.searchText.isEmpty
                ? "No tasks yet"
                : "No matching tasks"
            )
            .font(
                .system(
                    size: 22,
                    weight: .bold,
                    design: .rounded
                )
            )

            Text(
                viewModel.searchText.isEmpty
                ? "Create your first task and start getting things done."
                : "Try another search or change your filter."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 35)

            if viewModel.searchText.isEmpty {

                Button {

                    showAddTask = true

                } label: {

                    Label(
                        "Create First Task",
                        systemImage: "plus"
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
                    .padding(
                        .horizontal,
                        20
                    )
                    .frame(height: 48)
                    .background(
                        AppTheme.Gradients.primary
                    )
                    .clipShape(
                        Capsule()
                    )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Error

    private func errorState(
        _ message: String
    ) -> some View {

        VStack(spacing: 16) {

            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .font(.system(size: 40))
            .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.title3.weight(.bold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Button("Try Again") {

                viewModel.startListening()

            }
            .fontWeight(.semibold)
            .foregroundStyle(
                AppTheme.Colors.primary
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Task List

    private var taskList: some View {

        ScrollView {

            LazyVStack(
                spacing: 14
            ) {

                ForEach(
                    viewModel.filteredTasks
                ) { task in

                    TaskCard(
                        task: task,
                        onToggle: {

                            Task {

                                await viewModel
                                    .toggleCompleted(
                                        task
                                    )
                            }
                        },
                        onEdit: {

                            selectedTask = task
                        },
                        onDelete: {

                            taskToDelete = task
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
    }
}
#Preview {
    TaskListView(viewModel:TaskViewModel())
}
