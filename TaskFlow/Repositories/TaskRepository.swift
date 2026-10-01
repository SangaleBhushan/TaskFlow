//
//  TaskRepository.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum TaskRepositoryError: LocalizedError {
    case unauthenticated

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            return "Your session has expired. Please sign in again."
        }
    }
}

protocol TaskRepositoryProtocol {

    func addTask(_ task: AppTask) async throws
    func updateTask(_ task: AppTask) async throws
    func deleteTask(id: String) async throws
    func setCompleted(id: String,isCompleted: Bool) async throws
    func observeTasks( onChange: @escaping (Result<[AppTask], Error>) -> Void) -> ListenerRegistration?
}

final class TaskRepository: TaskRepositoryProtocol {
    

    private let db = Firestore.firestore()

    private var tasksCollection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }

        return db.collection("users").document(uid).collection("tasks")
    }

    func addTask(_ task: AppTask) async throws {
        guard let tasksCollection else {
            throw TaskRepositoryError.unauthenticated
        }

        let data: [String: Any] = [
            "title": task.title,
            "description": task.taskDescription,
            "dueDate": Timestamp(date: task.dueDate),
            "isCompleted": task.isCompleted,
            "createdAt": Timestamp(date: task.createdAt),
            "updatedAt": Timestamp(date: task.updatedAt)
        ]

        try await tasksCollection.document(task.id).setData(data)
    }


    func updateTask(_ task: AppTask) async throws {
        guard let tasksCollection else {
            throw TaskRepositoryError.unauthenticated
        }

        let data: [String: Any] = [
            "title": task.title,
            "description": task.taskDescription,
            "dueDate": Timestamp(date: task.dueDate),
            "isCompleted": task.isCompleted,
            "updatedAt": Timestamp(date: Date())
        ]

        try await tasksCollection.document(task.id).updateData(data)
    }

    func deleteTask(id: String) async throws {
        guard let tasksCollection else {
            throw TaskRepositoryError.unauthenticated
        }

        try await tasksCollection.document(id).delete()
    }
    
    func setCompleted(id: String,isCompleted: Bool) async throws {

        guard let tasksCollection else {
            throw TaskRepositoryError.unauthenticated
        }

        try await tasksCollection.document(id).updateData(["isCompleted": isCompleted,"updatedAt": Timestamp(date: Date())])
    }

    func observeTasks( onChange: @escaping (Result<[AppTask], Error>) -> Void) -> ListenerRegistration? {

        guard let tasksCollection else {
            onChange(.failure(TaskRepositoryError.unauthenticated))
            return nil
        }

        return tasksCollection.order(by: "dueDate").addSnapshotListener { snapshot, error in

                if let error {
                    onChange(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    onChange(.success([]))
                    return
                }

                let tasks = documents.compactMap {
                    self.mapDocument($0)
                }

                onChange(.success(tasks))
            }
    }
    // MARK: - Mapping

    private func mapDocument(_ document: QueryDocumentSnapshot) -> AppTask? {

        let data = document.data()

        guard
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let dueTimestamp = data["dueDate"] as? Timestamp,
            let isCompleted = data["isCompleted"] as? Bool,
            let createdTimestamp = data["createdAt"] as? Timestamp,
            let updatedTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }

        return AppTask(
            id: document.documentID,
            title: title,
            taskDescription: description,
            dueDate: dueTimestamp.dateValue(),
            isCompleted: isCompleted,
            createdAt: createdTimestamp.dateValue(),
            updatedAt: updatedTimestamp.dateValue()
        )
    }
    
}
