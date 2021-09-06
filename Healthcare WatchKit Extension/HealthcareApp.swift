//
//  HealthcareApp.swift
//  Healthcare WatchKit Extension
//
//  Created by T T on 2021/08/15.
//

import SwiftUI

@main
struct HealthcareApp: App {
    
    @StateObject private var workoutManager = WorkoutManager()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(workoutManager)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
