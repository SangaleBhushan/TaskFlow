//
//  AppTask.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import Foundation

struct AppTask: Identifiable, Codable, Equatable {

    let id: String
    var title: String
    var taskDescription: String
    var dueDate: Date

    var isCompleted: Bool

    let createdAt: Date
    var updatedAt: Date

    var status: TaskStatus {
        isCompleted ? .completed : .pending
    }

    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
}

enum TaskStatus: String, Codable {
    case pending
    case completed
}
