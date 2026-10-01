# TaskFlow

A modern SwiftUI task management application built with **Swift 5+, SwiftUI, Firebase Authentication, Cloud Firestore, Combine, and MVVM**.

TaskFlow demonstrates a production-oriented iOS architecture with authentication, real-time task management, dashboard analytics, search/filtering, offline awareness, dark mode, validation, graceful error handling, and unit testing.

---

## Features

### Authentication
- Email/password sign up
- Email/password sign in
- Password reset
- Firebase Authentication session persistence
- Validation for email and password
- User-friendly authentication error messages
- Logout

### Task Management
- Create tasks
- Edit tasks
- Delete tasks
- Mark tasks as completed/pending
- Due date selection
- Task title and description
- Real-time Firestore updates
- Task status indicators
- Overdue task detection
- Search by title or description
- Filter by:
  - All
  - Pending
  - Completed
  - Overdue

### Dashboard
- Total task count
- Pending task count
- Completed task count
- Overdue task count
- Completion progress
- Swift Charts visualization
- Quick navigation to task lists

### UI / UX
- SwiftUI-based interface
- Modern glass/material UI
- Responsive layouts
- Light and dark mode
- Animated launch screen
- Loading states
- Empty states
- Error states
- Global offline banner
- Smooth navigation and transitions

### Offline Awareness
TaskFlow monitors network connectivity using `NWPathMonitor`.

When the device becomes offline, the application displays an offline banner and informs the user that changes can synchronize when connectivity is restored.

Firestore's built-in offline capabilities can also support local persistence and synchronization behavior.

### Unit Testing
The project includes unit tests for core business logic:

- `AppTaskTests`
- `TaskViewModelTests`
- `AuthViewModelTests`

The tests cover task status, overdue logic, task counts, progress calculation, filtering, search, validation, repository failures, login validation, and successful authentication flows using mock repositories.

---

# Tech Stack

| Technology | Purpose |
|---|---|
| Swift | Application development |
| SwiftUI | User interface |
| Combine | Observable state / MVVM |
| Firebase Authentication | User authentication |
| Cloud Firestore | Real-time task persistence |
| Swift Charts | Dashboard analytics |
| Network.framework | Network connectivity monitoring |
| XCTest | Unit testing |
| Xcode | Development environment |

---

# Architecture

TaskFlow follows an **MVVM + Repository** architecture.

```text
                    ┌─────────────────┐
                    │     SwiftUI     │
                    │      Views      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   ViewModels    │
                    │                 │
                    │ AuthViewModel   │
                    │ TaskViewModel   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Repository    │
                    │     Layer       │
                    │                 │
                    │ AuthRepository  │
                    │ TaskRepository  │
                    └────────┬────────┘
                             │
                             ▼
                 ┌───────────────────────┐
                 │        Firebase       │
                 │                       │
                 │ Firebase Auth         │
                 │ Cloud Firestore      │
                 └───────────────────────┘
```

### Data Flow

```text
User Action
    ↓
SwiftUI View
    ↓
ViewModel
    ↓
Repository
    ↓
Firebase
    ↓
Repository
    ↓
ViewModel @Published State
    ↓
SwiftUI View Updates
```

This keeps Firebase-specific implementation details out of the UI layer and makes ViewModels easier to test using mock repositories.

---

# Project Structure

```text
TaskFlow/
│
├── App/
│   ├── TaskFlowApp.swift
│   ├── AppRouter.swift
│   └── RootView.swift
│
├── Core/
│   ├── Firebase/
│   │   ├── FirebaseErrorMapper.swift
│   │   └── FirebaseManager.swift
│   │
│   ├── Network/
│   │   └── NetworkStatus.swift
│   │
│   └── Theme/
│       └── AppTheme.swift
│
├── Models/
│   └── AppTask.swift
│
├── Repositories/
│   ├── AuthRepository.swift
│   └── TaskRepository.swift
│
├── ViewModels/
│   ├── AuthViewModel.swift
│   └── TaskViewModel.swift
│
├── Views/
│   ├── Launch/
│   ├── Authentication/
│   ├── Dashboard/
│   ├── Tasks/
│   └── Components/
│
└── TaskFlowTests/
    ├── AppTaskTests.swift
    ├── TaskViewModelTests.swift
    └── AuthViewModelTests.swift
```

---

# Firebase Setup

TaskFlow uses Firebase Authentication and Cloud Firestore.

## 1. Create a Firebase project

Create a Firebase project from the Firebase Console.

Add an iOS application using the bundle identifier configured in the Xcode project.

## 2. Add GoogleService-Info.plist

Download the Firebase configuration file and add:

```text
GoogleService-Info.plist
```

to the `TaskFlow` application target.

Make sure:

```text
Copy items if needed
```

is selected and the file is included in the `TaskFlow` target.

## 3. Enable Authentication

In Firebase Console:

```text
Authentication
→ Sign-in method
→ Email/Password
→ Enable
```

## 4. Create Firestore Database

Enable Cloud Firestore for the Firebase project.

TaskFlow stores tasks under each authenticated user's document.

---

# Firestore Structure

```text
users
 └── {userId}
      └── tasks
           └── {taskId}
                ├── title
                ├── description
                ├── dueDate
                ├── isCompleted
                ├── createdAt
                └── updatedAt
```

Each authenticated user has an isolated task collection.

---

# Firestore Security Rules

The application uses user-specific Firestore access.

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId}/tasks/{taskId} {

      allow read, write:
        if request.auth != null
        && request.auth.uid == userId;
    }
  }
}
```

This ensures an authenticated user can only access tasks belonging to their own Firebase UID.

---

# Authentication Flow

```text
Launch
  ↓
Firebase Auth State
  ↓
Authenticated?
  ├── Yes → Dashboard
  │
  └── No  → Login
              │
              ├── Sign In
              ├── Sign Up
              └── Forgot Password
```

Firebase Authentication maintains the user's session, allowing the application to restore the authenticated state when the app is reopened.

---

# Task Flow

```text
Dashboard
    ↓
Task List
    ↓
Create / Edit Task
    ↓
TaskViewModel
    ↓
TaskRepository
    ↓
Cloud Firestore
    ↓
Snapshot Listener
    ↓
Updated Task List
```

The Firestore snapshot listener provides real-time updates to the task list.

---

# Validation

Task creation and editing enforce:

### Title

The title cannot be empty or contain only whitespace.

```text
Task title is required.
```

### Due Date

The due date cannot be in the past.

```text
Due date cannot be in the past.
```

Validation is performed inside `TaskViewModel`, keeping business rules outside the SwiftUI views.

---

# Error Handling

Firebase and repository errors are mapped into user-friendly messages.

Examples:

```text
Permission denied
→ You don't have permission to access this task.

Service unavailable
→ You're temporarily offline. Please try again when you're connected.

Task not found
→ This task no longer exists.

Authentication failure
→ A user-friendly authentication error is displayed.
```

The UI avoids exposing raw Firebase error messages directly to users.

---

# Testing

Run the unit test suite using:

```text
⌘ + U
```

The test target is:

```text
TaskFlowTests
```

### Current unit-test coverage

#### AppTaskTests

Tests:

- Pending task status
- Completed task status
- Overdue pending tasks
- Completed tasks with past dates

#### TaskViewModelTests

Tests:

- Total task count
- Completed count
- Pending count
- Completion progress
- Pending filter
- Completed filter
- Overdue filter
- Search by title
- Search by description
- Empty title validation
- Past due-date validation
- Successful task creation
- Repository error handling

#### AuthViewModelTests

Tests:

- Empty email validation
- Invalid email validation
- Empty password validation
- Successful sign in
- Email trimming
- Authentication error handling

Repository protocols are mocked so the tests do not require real Firebase network calls.

---

# Manual QA Checklist

Before submitting the application, verify the following:

### Authentication

- [ ] App launches correctly
- [ ] Sign up with a new account
- [ ] Login with valid credentials
- [ ] Invalid email validation
- [ ] Empty password validation
- [ ] Invalid credentials show an error
- [ ] Password reset works
- [ ] Authenticated session persists
- [ ] Logout works

### Tasks

- [ ] Create task
- [ ] Empty title rejected
- [ ] Past due date rejected
- [ ] Edit task
- [ ] Complete task
- [ ] Re-open completed task
- [ ] Delete task
- [ ] Task list updates in real time
- [ ] Search works
- [ ] Filters work
- [ ] Overdue status works

### Dashboard

- [ ] Total count is correct
- [ ] Pending count is correct
- [ ] Completed count is correct
- [ ] Overdue count is correct
- [ ] Progress calculation is correct
- [ ] Chart updates after task changes
- [ ] View All navigation works

### UI

- [ ] Light mode works
- [ ] Dark mode works
- [ ] Loading states appear correctly
- [ ] Empty states appear correctly
- [ ] Error states are understandable
- [ ] Offline banner appears when network is unavailable
- [ ] Layout works across supported screen sizes

---

# Dark Mode

TaskFlow provides a user-controlled dark mode setting.

The setting is persisted using:

```swift
@AppStorage("isDarkMode")
```

The selected appearance is applied globally through:

```swift
.preferredColorScheme(...)
```

This means the user's selected appearance is preserved between app launches.

---

# Design Decisions

### MVVM

MVVM separates UI rendering from business logic and state management.

### Repository Pattern

Repositories isolate Firebase implementation from ViewModels.

This also makes unit testing easier because repositories can be replaced with mocks.

### Real-Time Firestore Listener

A snapshot listener keeps the task list synchronized with Firestore without requiring manual refresh operations.

### Protocol-Based Dependencies

Protocols such as:

```swift
AuthRepositoryProtocol
TaskRepositoryProtocol
```

allow production Firebase implementations to be replaced with test doubles.

### Centralized Error Mapping

Firebase errors are converted into user-facing messages through a centralized error-mapping layer.

### Network Monitoring

`NWPathMonitor` provides immediate UI feedback when the device loses network connectivity.

---

# Future Enhancements

## Firebase Cloud Messaging

Push notifications can be added to provide task reminder notifications.

A production FCM implementation would include:

```text
Task due date
      ↓
Backend / scheduled notification
      ↓
Firebase Cloud Messaging
      ↓
APNs
      ↓
iOS device
      ↓
TaskFlow notification
```

End-to-end APNs push notification testing requires appropriate Apple Developer provisioning and a physical iOS device.

FCM notifications are therefore documented as a future enhancement rather than presented as an implemented feature.

Other possible enhancements:

- Recurring tasks
- Task categories
- Priority levels
- Attachments
- More advanced analytics
- Cloud Functions for scheduled reminders
- Pagination for very large task collections

---

# Getting Started

## Requirements

- macOS
- Xcode 27+
- iOS 18+
- Swift 5+
- Firebase project
- Firebase Authentication enabled
- Cloud Firestore enabled

## Installation

Clone the repository:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
```

Open:

```text
TaskFlow.xcodeproj
```

Configure Firebase using your own:

```text
GoogleService-Info.plist
```

Resolve Swift Package dependencies.

Build and run:

```text
⌘ + R
```

Run unit tests:

```text
⌘ + U
```

---

# Important Security Note

Do not commit private credentials, service-account keys, or other server-side Firebase credentials to source control.

For a public repository, configure Firebase using your own project configuration and review repository history before publishing.

Firestore security rules must always be configured in Firebase Console; client-side validation alone is not a security boundary.

---

# Assignment Coverage

| Requirement | Status |
|---|---|
| Swift / SwiftUI | ✅ |
| MVVM | ✅ |
| Combine | ✅ |
| Firebase Authentication | ✅ |
| Email/password login | ✅ |
| Signup | ✅ |
| Password reset | ✅ |
| Session persistence | ✅ |
| Firestore | ✅ |
| CRUD operations | ✅ |
| Real-time updates | ✅ |
| Task validation | ✅ |
| Dashboard | ✅ |
| Swift Charts | ✅ |
| Search | ✅ |
| Filtering | ✅ |
| Dark mode | ✅ |
| Offline awareness | ✅ |
| Graceful error handling | ✅ |
| Unit testing | ✅ |
| FCM reminders | Future enhancement |

---

# Author

**Bhushan Sangale**

Software Engineer | iOS & Generative AI

