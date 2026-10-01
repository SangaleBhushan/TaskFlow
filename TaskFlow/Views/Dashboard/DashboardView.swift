//
//  DashboardView.swift
//  TaskFlow
//
//  Created by Bhushan Sangale on 30/09/26.
//

import SwiftUI
import Charts
import FirebaseAuth

struct DashboardView: View {

    @EnvironmentObject private var router: AppRouter
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var selectedTab = 0
    @State private var showAddTask = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        
        
        TabView(selection: $selectedTab){
            
            overviewTab
                .tabItem {
                    Label("Overview", systemImage: "rectangle.grid.2x2.fill")
                }.tag(0)
            
            TaskListView(viewModel: taskViewModel)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                } .tag(1)
            
            profileTab
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }.tag(2)
            
        }.tint(AppTheme.Colors.primary)
            .task {
                taskViewModel.startListening()
            }
    }

    // MARK: - Overview

    private var overviewTab: some View {

        NavigationStack {

            ZStack {

                LinearGradient(
                    colors: [Color.indigo.opacity(0.12),Color.purple.opacity(0.08),Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()

                ScrollView(.vertical,showsIndicators: false){

                    VStack(alignment: .leading,spacing: 22){

                        header
                        statistics
                        progressCard
                        upcomingTasks
                        quickAction
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }.navigationBarHidden(true)
            
        }.sheet(isPresented: $showAddTask) {
            AddTaskView(viewModel: taskViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(alignment: .leading,spacing: 6){

            Text(greeting)
                .font(.system(size: 14,weight: .semibold))
                .foregroundStyle(AppTheme.Colors.primary)

            HStack {

                VStack(alignment: .leading,spacing: 5){

                    Text("Your productivity")
                        .font(.system(size: 30,weight: .bold,design: .rounded))

                    Text("Plan your day. Get things done.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {

                    Circle()
                        .fill(AppTheme.Gradients.primary)
                        .frame(width: 54,height: 54)

                    Image(systemName: "checkmark")
                        .font(.system(size: 22,weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Statistics

    private var statistics: some View {

        HStack(spacing: 12) {

            DashboardStatCard(
                title: "Total",
                value: taskViewModel.totalCount,
                icon: "checklist",
                tint: .indigo
            )

            DashboardStatCard(
                title: "Pending",
                value: taskViewModel.pendingCount,
                icon: "clock.fill",
                tint: .orange
            )

            DashboardStatCard(
                title: "Done",
                value: taskViewModel.completedCount,
                icon: "checkmark.circle.fill",
                tint: .green
            )
        }
    }

    // MARK: - Progress

    private var progressCard: some View {

        VStack(alignment: .leading,spacing: 20){

            HStack {
                VStack(alignment: .leading,spacing: 5){

                    Text("Task Overview")
                        .font(.system(size: 21,weight: .bold,design: .rounded))

                    Text("Your current productivity")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            
            ZStack {
                Chart {
                    SectorMark(
                        angle: .value( "Completed",taskViewModel.completedCount),
                        innerRadius: .ratio(0.62),
                        angularInset: 3
                    ).foregroundStyle(.green.gradient)
                     .cornerRadius(6)

                    SectorMark(
                        angle: .value( "Pending",taskViewModel.pendingCount),
                        innerRadius: .ratio(0.62),
                        angularInset: 3
                    ).foregroundStyle(.orange.gradient)
                     .cornerRadius(6)
                }
                .chartLegend(.hidden)
                .frame(height: 220)

                VStack(spacing: 4) {

                    Text("\(Int(taskViewModel.completionProgress * 100))%")
                    .font(.system(size: 30,weight: .bold,design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary)

                    Text("completed")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 24) {

                chartLegend(
                    title: "Completed",
                    value: taskViewModel.completedCount,
                    color: .green
                )

                chartLegend(
                    title: "Pending",
                    value: taskViewModel.pendingCount,
                    color: .orange
                )

                Spacer()
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26)
            .stroke(.white.opacity(0.25),lineWidth: 1)
        }.shadow(color: .black.opacity(0.08),radius: 20,y: 10)
    }

    // MARK: - Upcoming Tasks

    private var upcomingTasks: some View {

        VStack(alignment: .leading,spacing: 14){

            HStack {

                Text("Upcoming")
                    .font(.system(size: 20,weight: .bold))
                Spacer()
                Button("View all") {
                    selectedTab = 1
                }.font(.system(size: 14,weight: .semibold))
                 .foregroundStyle(AppTheme.Colors.primary)
            }

            let upcoming = taskViewModel.tasks
                .filter {  !$0.isCompleted && $0.dueDate >= Date() }
                .sorted {  $0.dueDate < $1.dueDate}

            if upcoming.isEmpty {

                HStack(spacing: 14) {

                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(AppTheme.Colors.primary)

                    VStack(alignment: .leading,spacing: 4){

                        Text("You're all caught up!")
                            .font(.system(size: 15,weight: .semibold))

                        Text("No upcoming tasks right now.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(18)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            } else {

                ForEach(Array(upcoming.prefix(3))){ task in
                    dashboardTaskRow(task)
                }
            }
        }
    }

    // MARK: - Task Row

    private func dashboardTaskRow(_ task: AppTask) -> some View {

        HStack(spacing: 14) {

            Circle()
                .fill(task.isOverdue  ? Color.red.opacity(0.15) : Color.indigo.opacity(0.12))
                .frame(width: 42,height: 42)
                .overlay {
                    Image(systemName: task.isOverdue ? "exclamationmark" : "calendar")
                    .foregroundStyle(task.isOverdue ? .red : AppTheme.Colors.primary)
                }

            VStack(alignment: .leading,spacing: 5){

                Text(task.title)
                    .font(.system(size: 15,weight: .semibold))
                    .lineLimit(1)

                Text(task.dueDate,style: .date)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Quick Action

    private var quickAction: some View {

        Button {
            showAddTask = true
        } label: {

            HStack(spacing: 14) {

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 48,height: 48)

                    Image(systemName: "plus")
                        .font(.system(size: 22,weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading,spacing: 3){

                    Text("Create a new task")
                        .font(.system(size: 16,weight: .bold))
                        .foregroundStyle(.white)

                    Text("Stay on top of your day")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "arrow.right")
                .foregroundStyle(.white)
            }
            .padding(16)
            .background(AppTheme.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .indigo.opacity(0.25),radius: 15,y: 8)
        }.buttonStyle(.plain)
    }


    private var profileTab: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.indigo.opacity(0.12),Color.purple.opacity(0.08),Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        VStack(spacing: 14) {
                            ZStack {
                                Circle().fill(.ultraThinMaterial)
                                    .frame(width: 110, height: 110)
                                    .overlay {
                                        Circle().stroke(.white.opacity(0.35),lineWidth: 1)
                                    }

                                Circle()
                                    .fill(AppTheme.Gradients.primary)
                                    .frame(width: 92, height: 92)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 38, weight: .semibold))
                                    .foregroundStyle(.white)
                            }

                            VStack(spacing: 5) {
                                Text("Welcome back")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(AuthRepository().currentUser()?.email ?? "User")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(.white.opacity(0.25),lineWidth: 1)
                                }
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            sectionTitle("Preferences")

                            VStack(spacing: 0) {
                                Toggle(isOn: $isDarkMode) {
                                    HStack(spacing: 14) {
                                        iconContainer(systemName: "moon.fill")

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("Dark Mode")
                                                .font(.system( size: 16, weight: .semibold))

                                            Text("Use a darker appearance")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .tint(AppTheme.Colors.primary)
                                .padding(18)
                            }
                            .background {
                                glassBackground()
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            sectionTitle("Account")

                            VStack(spacing: 0) {

                                HStack(spacing: 14) {
                                    iconContainer(systemName: "person.crop.circle")

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Account")
                                            .font(.system( size: 16,weight: .semibold))

                                        Text("Signed in with email")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }.padding(18)

                                Divider().padding(.leading, 70)

                                Button {
                                    do {
                                        try AuthRepository().signOut()
                                        router.showLogin()
                                    } catch {
                                        print(error)
                                    }
                                } label: {
                                    HStack(spacing: 14) {
                                        iconContainer(systemName: "rectangle.portrait.and.arrow.right",color: .red)

                                        Text("Sign Out")
                                            .font(.system(size: 16,weight: .semibold))
                                            .foregroundStyle(.red)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(18)
                                }
                            }
                            .background {
                                glassBackground()
                            }
                        }

                        VStack(spacing: 5) {
                            Text("TaskFlow")
                                .font(.system(size: 15, weight: .bold, design: .rounded))

                            Text("Plan. Do. Done.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("Version 1.0")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .padding(.top, 2)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.secondary)
            .tracking(1)
            .padding(.horizontal, 4)
    }
    
    private func iconContainer(systemName: String,color: Color = AppTheme.Colors.primary) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.12))
                .frame(width: 42, height: 42)

            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
        }
    }
    private func glassBackground() -> some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.white.opacity(0.22),lineWidth: 1)
            }
    }

    private var greeting: String {

        let hour = Calendar.current.component(.hour,from: Date())

        switch hour {

        case 5..<12:
            return "Good morning ☀️"

        case 12..<17:
            return "Good afternoon 🌤️"

        case 17..<22:
            return "Good evening 🌙"

        default:
            return "Welcome back 🌙"
        }
    }
    private func chartLegend(title: String,value: Int, color: Color) -> some View {

        HStack(spacing: 8) {

            Circle()
                .fill(color)
                .frame(width: 9,height: 9)

            VStack(alignment: .leading,spacing: 2){

                Text(title)
                    .font(.system(size: 12,weight: .medium))
                    .foregroundStyle(.secondary)

                Text("\(value)")
                    .font(.system(size: 15,weight: .bold))
            }
        }
    }
}
