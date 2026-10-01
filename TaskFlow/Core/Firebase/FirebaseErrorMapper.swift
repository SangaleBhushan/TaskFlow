//
//  FirebaseErrorMapper.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import FirebaseAuth
import FirebaseFirestore

enum FirebaseErrorMapper {

    static func message(for error: Error) -> String {

        if let repositoryError = error as? TaskRepositoryError {
            return repositoryError.localizedDescription
        }

        let nsError = error as NSError

        if nsError.domain == FirestoreErrorDomain {

            switch FirestoreErrorCode.Code(rawValue: nsError.code) {

            case .permissionDenied:
                return "You don't have permission to access this task."

            case .unavailable:
                return "You're temporarily offline. Please try again when you're connected."

            case .notFound:
                return "This task no longer exists."

            case .deadlineExceeded:
                return "The request took too long. Please try again."

            case .cancelled:
                return "The operation was cancelled."

            default:
                break
            }
        }

        return "Something went wrong. Please try again."
    }
}
