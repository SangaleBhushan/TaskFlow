//
//  AppTaskTests.swift
//  TaskFlowTests
//
//  Created by Bhushan Sangale on 01/10/26.
//

import XCTest
@testable import TaskFlow

final class AppTaskTests: XCTestCase {

    func testTaskStatusIsPendingWhenNotCompleted() {
        let task = AppTask(
            id: "1",
            title: "Test Task",
            taskDescription: "Test description",
            dueDate: Date().addingTimeInterval(3600),
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(task.status, .pending)
    }

    func testTaskStatusIsCompletedWhenCompleted() {
        let task = AppTask(
            id: "1",
            title: "Test Task",
            taskDescription: "Test description",
            dueDate: Date().addingTimeInterval(3600),
            isCompleted: true,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(task.status, .completed)
    }

    func testPendingTaskWithPastDueDateIsOverdue() {
        let task = AppTask(
            id: "1",
            title: "Overdue Task",
            taskDescription: "",
            dueDate: Date().addingTimeInterval(-3600),
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertTrue(task.isOverdue)
    }

    func testCompletedTaskWithPastDueDateIsNotOverdue() {
        let task = AppTask(
            id: "1",
            title: "Completed Task",
            taskDescription: "",
            dueDate: Date().addingTimeInterval(-3600),
            isCompleted: true,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertFalse(task.isOverdue)
    }
}
