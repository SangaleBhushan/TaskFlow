//
//  AddTaskView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 01/10/26.
//

import SwiftUI

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @FocusState private var focusedField: Field?
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(3600)

    @State private var showDatePicker = false
    @State private var showValidationError = false

    enum Field {
        case title
        case description
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&  dueDate >= Date()
    }

    var body: some View {

        NavigationStack {

            ZStack {
                background

                ScrollView {
                    formContent
                }

                if viewModel.isSaving {
                    LoadingOverlay(title: "Creating task...",message: "Saving your task securely")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarLeading){

                    Button {
                        dismiss()
                    } label: {

                        Image(systemName: "xmark")
                            .font(.system(size: 15,weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 34,height: 34)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }.disabled(viewModel.isSaving)
                }

                ToolbarItem(placement: .principal) {

                    Text("New Task")
                        .font(.system(size: 17,weight: .bold,design: .rounded))
                }
            }
            .toolbar {

                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.isSaving)
    }

    // MARK: - Background

    private var background: some View {

        LinearGradient(
            colors: [
                AppTheme.Colors.primary.opacity(0.10),
                AppTheme.Colors.secondary.opacity(0.06),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Form

    private var formContent: some View {

        VStack(alignment: .leading,spacing: 24){

            hero
            titleField
            descriptionField
            dueDateSection

            if let error = viewModel.errorMessage {
                errorBanner(error)
            }

            createButton

            Spacer(minLength: 30)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    // MARK: - Hero

    private var hero: some View {

        VStack(alignment: .leading,spacing: 8){

            ZStack {

                Circle()
                    .fill(AppTheme.Colors.primary.opacity(0.12))
                    .frame(width: 58,height: 58)

                Image(systemName: "plus")
                    .font(.system(size: 24,weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
            }

            Text("Create something")
                .font(.system(size: 30,weight: .bold,design: .rounded))

            Text("worth getting done.")
                .font(.system(size: 30,weight: .bold,design: .rounded))
                .foregroundStyle(AppTheme.Colors.primary )

            Text("Add the details now and we'll keep it organized for you." )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
    }

    // MARK: - Title

    private var titleField: some View {

        VStack(alignment: .leading,spacing: 9){

            fieldLabel(title: "TASK TITLE",icon: "text.cursor")

            HStack(spacing: 12) {

                Image(systemName: "checkmark.circle").foregroundStyle(AppTheme.Colors.primary)

                TextField("What needs to be done?",text: $title)
                .focused($focusedField,equals: .title)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .description
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(.ultraThinMaterial)
            .clipShape( RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                .stroke(focusedField == .title ? AppTheme.Colors.primary.opacity(0.6) : .white.opacity(0.2),lineWidth: 1)
            }
        }
    }

    // MARK: - Description

    private var descriptionField: some View {

        VStack(alignment: .leading,spacing: 9){

            fieldLabel(title: "DESCRIPTION",icon: "text.alignleft")

            ZStack(alignment: .topLeading) {

                if description.isEmpty {

                    Text("Add some context about this task...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal,16)
                        .padding(.vertical,16)
                }

                TextEditor(text: $description)
                .focused( $focusedField,equals: .description)
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 130)
                .background(.clear)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                .stroke(focusedField == .description ? AppTheme.Colors.primary.opacity(0.6) : .white.opacity(0.2), lineWidth: 1)
            }
        }
    }

    // MARK: - Due Date

    private var dueDateSection: some View {

        VStack(alignment: .leading,spacing: 9){

            fieldLabel(title: "DUE DATE",icon: "calendar")

            Button {

                focusedField = nil
                withAnimation(.easeInOut(duration: 0.25)) {
                    showDatePicker.toggle()
                }

            } label: {

                HStack(spacing: 14) {

                    Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundStyle(AppTheme.Colors.primary)

                    VStack(alignment: .leading,spacing: 3){

                        Text(dueDate,format: .dateTime .weekday(.wide).month(.abbreviated).day())
                        .font(.system(size: 16,weight: .semibold))
                        .foregroundStyle(.primary)

                        Text(dueDate,format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2),lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            if showDatePicker {

                DatePicker("Due date",selection: $dueDate,in: Date()...,
                    displayedComponents: [.date,.hourAndMinute])
                .datePickerStyle(.graphical)
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Create

    private var createButton: some View {

        Button {
            focusedField = nil
            Task {

                let success =  await viewModel.addTask( title: title,description: description,dueDate: dueDate)

                if success {
                    dismiss()
                }
            }

        } label: {

            HStack(spacing: 10) {

                Text("Create Task")
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 17,weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(isFormValid ? AnyShapeStyle( AppTheme.Gradients.primary): AnyShapeStyle(Color.secondary.opacity(0.25)))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow( color: isFormValid ? .black.opacity(0.12)  : .clear, radius: 12, y: 6)
        }
        .disabled(!isFormValid ||  viewModel.isSaving)
        .animation(.easeInOut(duration: 0.2),value: isFormValid)
    }

    // MARK: - Error

    private func errorBanner( _ message: String) -> some View {

        HStack(alignment: .top,spacing: 10) {

            Image(systemName:"exclamationmark.triangle.fill")
            .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.08))
        .clipShape( RoundedRectangle(cornerRadius: 14))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Field Label

    private func fieldLabel(title: String,icon: String) -> some View {

        Label {
            Text(title)
                .font(.system(size: 12,weight: .bold))
                .tracking(0.7)

        } icon: {
            Image(systemName: icon)
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    AddTaskView(viewModel: TaskViewModel())
}
