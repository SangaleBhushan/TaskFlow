//
//  TaskViewModel.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class TaskViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var tasks: [AppTask] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: TaskFilter = .all

    private let repository: TaskRepositoryProtocol

    private var listener: ListenerRegistration?

    // MARK: - Init

    init(repository: TaskRepositoryProtocol = TaskRepository()){
        self.repository = repository
    }

    deinit {
        listener?.remove()
    }


    var filteredTasks: [AppTask] {

        var result = tasks

        switch selectedFilter {

        case .all:
            break

        case .pending:
            result = result.filter {!$0.isCompleted}

        case .completed:
            result = result.filter {$0.isCompleted}

        case .overdue:
            result = result.filter {$0.isOverdue}
        }

        let search = searchText .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !search.isEmpty else {
            return result
        }

        return result.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||  $0.taskDescription.localizedCaseInsensitiveContains(search)
        }
    }


    var totalCount: Int {
        tasks.count
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var pendingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    var overdueCount: Int {
        tasks.filter(\.isOverdue).count
    }

    var completionProgress: Double {

        guard totalCount > 0 else {
            return 0
        }

        return Double(completedCount) / Double(totalCount)
    }


    func startListening() {

        guard listener == nil else {
            return
        }

        isLoading = true
        errorMessage = nil

        listener = repository.observeTasks { [weak self] result in

            Task { @MainActor in

                guard let self else {
                    return
                }

                self.isLoading = false

                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                    
                case .failure(let error):
                    self.errorMessage = self.message(for: error)
                }
            }
        }
    }


    func addTask(title: String,description: String,dueDate: Date) async -> Bool {

        guard validate(title: title,dueDate: dueDate) else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        let now = Date()

        let task = AppTask(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            taskDescription: description.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate,
            isCompleted: false,
            createdAt: now,
            updatedAt: now
        )

        do {
            try await repository.addTask(task)
            return true

        } catch {
            errorMessage = message(for: error)
            return false
        }
    }


    func updateTask(_ task: AppTask) async -> Bool {

        guard validate(title: task.title,dueDate: task.dueDate) else {
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }
        do {

            try await repository.updateTask(task)
            return true

        } catch {
            errorMessage = message(for: error)
            return false
        }
    }

    func toggleCompleted(_ task: AppTask) async {

        errorMessage = nil

        do {
            try await repository.setCompleted(id: task.id,isCompleted: !task.isCompleted)
        } catch {
            errorMessage = message(for: error)
        }
    }


    func deleteTask(_ task: AppTask) async {

        errorMessage = nil
        do {
            try await repository.deleteTask(id: task.id)

        } catch {
            errorMessage = message(for: error)
        }
    }

    private func validate(title: String,dueDate: Date) -> Bool {

        if title.trimmingCharacters( in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Task title is required."
            return false
        }

        if dueDate < Date() {

            errorMessage =  "Due date cannot be in the past."
            return false
        }

        return true
    }

    private func message(for error: Error) -> String {

        let nsError = error as NSError
        if nsError.domain == FirestoreErrorDomain {
            switch FirestoreErrorCode.Code(rawValue: nsError.code)  {
            case .permissionDenied:
                return "You don't have permission to modify this task."

            case .unavailable:
                return "Service temporarily unavailable. Please try again."

            case .notFound:
                return "Network connection lost. Please try again."

            default:
                break
            }
        }

        return "Something went wrong. Please try again."
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

#if DEBUG
extension TaskViewModel {
    func setTasksForUnitTesting(_ tasks: [AppTask]) {
        self.tasks = tasks
    }
}
#endif

enum TaskFilter: String, CaseIterable, Identifiable {

    case all
    case pending
    case completed
    case overdue

    var id: String {
        rawValue
    }

    var title: String {

        switch self {
        case .all:
            return "All"
        case .pending:
            return "Pending"
        case .completed:
            return "Completed"
        case .overdue:
            return "Overdue"
        }
    }

    var icon: String {
        switch self {
        case .all:
            return "square.grid.2x2"
        case .pending:
            return "clock"
        case .completed:
            return "checkmark.circle"
        case .overdue:
            return "exclamationmark.triangle"
        }
    }
}
