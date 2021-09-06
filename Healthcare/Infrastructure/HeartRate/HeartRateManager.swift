//
//  HeartRateManager.swift
//  Healthcare
//
//  Created by Shin on 2021/05/31.
//

import Foundation
import UIKit
import HealthKit

class HeartRateManager {
    
    private let healthStore = HKHealthStore()
    
    func startWatchApp(handler: @escaping (Error?) -> Void) {
        
        WatchConnectivityManager.shared.fetchActivatedSession { _ in
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor

            self.healthStore.startWatchApp(with: configuration) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("healthStore.startWatchApp error:", error)
                    } else {
                        print("healthStore.startWatchApp success.")
                    }
                    handler(error)
                }
            }
        }
    }
}

