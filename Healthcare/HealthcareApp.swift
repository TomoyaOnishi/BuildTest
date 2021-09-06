//
//  HealthcareApp.swift
//  Healthcare
//
//  Created by T T on 2021/08/15.
//

import SwiftUI
import Firebase
import HealthKit

@main
struct HealthcareApp: App {
    
    init() {
        FirebaseApp.configure()
        WatchConnectivityManager.shared.activate()

        if Auth.auth().currentUser?.uid == nil {
            Auth.auth().signInAnonymously() { (authResult, error) in
                print("ログイン")
            }
        }

        if HKHealthStore.isHealthDataAvailable() {
            let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            let typesToRead = Set([heartRateType,
                                   HKTypes.bodyMass.quantityType,
                                   HKTypes.bloodPressureSystolic.quantityType,
                                   HKTypes.bloodPressureDiastolic.quantityType,
                                   HKTypes.heartRate.quantityType
            ])
            let typesToShare = Set([ HKTypes.bodyMass.quantityType,
                                     HKTypes.bloodPressureSystolic.quantityType,
                                     HKTypes.bloodPressureDiastolic.quantityType,
                                     HKTypes.heartRate.quantityType

            ])

            HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in }
        }
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView(vm: ContentViewModel())
                .environmentObject(SettingEnvironmentObject())
        }
    }
}
