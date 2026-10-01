//
//  TaskViewModelTests.swift
//  TaskFlowTests
//
//  Created by Bhushan Sangale on 01/10/26.
//

import Foundation
import XCTest
import FirebaseFirestore
@testable import TaskFlow

@MainActor
final class TaskViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeTask(id: String = UUID().uuidString,title: String,completed: Bool = false,dueDate: Date = Date().addingTimeInterval(3600)) -> AppTask {
        AppTask(
            id: id,
            title: title,
            taskDescription: "Test description",
            dueDate: dueDate,
            isCompleted: completed,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    // MARK: - Counts

    func testTotalCount() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        repository.tasks = [
            makeTask(title: "Task 1"),
            makeTask(title: "Task 2"),
            makeTask(title: "Task 3")
        ]

        viewModel.setTasksForTesting(repository.tasks)

        XCTAssertEqual(viewModel.totalCount, 3)
    }

    func testCompletedAndPendingCount() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let tasks = [
            makeTask(title: "Pending 1"),
            makeTask(title: "Completed 1", completed: true),
            makeTask(title: "Pending 2"),
            makeTask(title: "Completed 2", completed: true)
        ]

        viewModel.setTasksForTesting(tasks)

        XCTAssertEqual(viewModel.completedCount, 2)
        XCTAssertEqual(viewModel.pendingCount, 2)
    }

    func testCompletionProgress() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let tasks = [
            makeTask(title: "Pending"),
            makeTask(title: "Completed 1", completed: true),
            makeTask(title: "Completed 2", completed: true),
            makeTask(title: "Completed 3", completed: true)
        ]

        viewModel.setTasksForTesting(tasks)

        XCTAssertEqual(viewModel.completionProgress, 0.75)
    }

    // MARK: - Filtering

    func testPendingFilter() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let tasks = [
            makeTask(title: "Pending"),
            makeTask(title: "Completed", completed: true)
        ]

        viewModel.setTasksForTesting(tasks)
        viewModel.selectedFilter = .pending

        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.filteredTasks.first?.title, "Pending")
    }

    func testCompletedFilter() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let tasks = [
            makeTask(title: "Pending"),
            makeTask(title: "Completed", completed: true)
        ]

        viewModel.setTasksForTesting(tasks)
        viewModel.selectedFilter = .completed

        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.filteredTasks.first?.title, "Completed")
    }

    func testOverdueFilter() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let tasks = [
            makeTask(
                title: "Overdue",
                dueDate: Date().addingTimeInterval(-3600)
            ),
            makeTask(
                title: "Future",
                dueDate: Date().addingTimeInterval(3600)
            )
        ]

        viewModel.setTasksForTesting(tasks)
        viewModel.selectedFilter = .overdue

        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.filteredTasks.first?.title, "Overdue")
    }

    // MARK: - Search

    func testSearchFiltersTasksByTitle() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let tasks = [
            makeTask(title: "Buy groceries"),
            makeTask(title: "Complete assignment"),
            makeTask(title: "Read book")
        ]

        viewModel.setTasksForTesting(tasks)
        viewModel.searchText = "assignment"

        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertEqual(
            viewModel.filteredTasks.first?.title,
            "Complete assignment"
        )
    }

    func testSearchFiltersTasksByDescription() {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let task = AppTask(
            id: "1",
            title: "Task",
            taskDescription: "Prepare Firebase documentation",
            dueDate: Date().addingTimeInterval(3600),
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        viewModel.setTasksForTesting([task])
        viewModel.searchText = "Firebase"

        XCTAssertEqual(viewModel.filteredTasks.count, 1)
    }

    // MARK: - Validation

    func testEmptyTitleIsRejected() async {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let result = await viewModel.addTask(
            title: "   ",
            description: "Description",
            dueDate: Date().addingTimeInterval(3600)
        )

        XCTAssertFalse(result)
        XCTAssertEqual(
            viewModel.errorMessage,
            "Task title is required."
        )
        XCTAssertNil(repository.addedTask)
    }

    func testPastDueDateIsRejected() async {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let result = await viewModel.addTask(
            title: "Valid task",
            description: "Description",
            dueDate: Date().addingTimeInterval(-3600)
        )

        XCTAssertFalse(result)
        XCTAssertEqual(
            viewModel.errorMessage,
            "Due date cannot be in the past."
        )
        XCTAssertNil(repository.addedTask)
    }

    // MARK: - Add Task

    func testAddTaskSuccessfullyCallsRepository() async {
        let repository = MockTaskRepository()
        let viewModel = TaskViewModel(repository: repository)

        let result = await viewModel.addTask(
            title: "  New Task  ",
            description: "  Test description  ",
            dueDate: Date().addingTimeInterval(3600)
        )

        XCTAssertTrue(result)
        XCTAssertNotNil(repository.addedTask)

        XCTAssertEqual(
            repository.addedTask?.title,
            "New Task"
        )

        XCTAssertEqual(
            repository.addedTask?.taskDescription,
            "Test description"
        )
    }

    func testAddTaskHandlesRepositoryError() async {
        let repository = MockTaskRepository()
        repository.shouldFail = true

        let viewModel = TaskViewModel(repository: repository)

        let result = await viewModel.addTask(
            title: "Valid Task",
            description: "Description",
            dueDate: Date().addingTimeInterval(3600)
        )

        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}

// MARK: - Mock Repository

private final class MockTaskRepository: TaskRepositoryProtocol {

    var tasks: [AppTask] = []
    var addedTask: AppTask?
    var shouldFail = false

    func addTask(_ task: AppTask) async throws {
        if shouldFail {
            throw MockTaskError.operationFailed
        }

        addedTask = task
        tasks.append(task)
    }

    func updateTask(_ task: AppTask) async throws {
        if shouldFail {
            throw MockTaskError.operationFailed
        }
    }

    func deleteTask(id: String) async throws {
        if shouldFail {
            throw MockTaskError.operationFailed
        }
    }

    func setCompleted(
        id: String,
        isCompleted: Bool
    ) async throws {
        if shouldFail {
            throw MockTaskError.operationFailed
        }
    }

    func observeTasks(
        onChange: @escaping (Result<[AppTask], Error>) -> Void
    ) -> ListenerRegistration? {
        nil
    }
}

private enum MockTaskError: Error {
    case operationFailed
}

// MARK: - Testing Helper

private extension TaskViewModel {

    func setTasksForTesting(_ tasks: [AppTask]) {
        self.setTasksForUnitTesting(tasks)
    }
}
