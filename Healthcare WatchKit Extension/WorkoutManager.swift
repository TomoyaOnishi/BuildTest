//
//  WorkoutManager.swift
//  HealthcareWatchKitApp Extension
//
//  Created by Shin on 2021/05/31.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
//    var selectedWorkout: HKWorkoutActivityType? {
//        didSet {
//            guard let selectedWorkout = selectedWorkout else { return }
//            startWorkout(workoutType: selectedWorkout)
//        }
//    }

//    @Published var showingSummaryView: Bool = false {
//        didSet {
//            if showingSummaryView == false {
//                resetWorkout()
//            }
//        }
//    }

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    // Start the workout.
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .indoor

        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }

        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self

        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)

        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
        }
    }

    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }

    // MARK: - Session State Control

    // The app's workout state.
    @Published var running = false

    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    func pause() {
        session?.pause()
        WatchConnectivityManager.shared.send([.workoutStop : true])
    }

    func resume() {
        session?.resume()
        WatchConnectivityManager.shared.send([.workoutStart : true])
    }

    func endWorkout() {
        session?.end()
//        showingSummaryView = true
    }

    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }

    func resetWorkout() {
//        selectedWorkout = nil
        builder = nil
        workout = nil
        session = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}

//class WorkoutManager {
//
//    static let shared = WorkoutManager()
//
//    private init() {}
//
//    let healthStore = HKHealthStore()
//
//    var isWorkoutSessionRunning: Bool {
//        return currentWorkoutSession != nil
//    }
//
//    private(set) var currentWorkoutSession: HKWorkoutSession?
//
//    func startWorkout(with configuration: HKWorkoutConfiguration) throws {
//
//        do {
//            let workoutSession = try HKWorkoutSession(configuration: configuration)
//            healthStore.start(workoutSession)
//            currentWorkoutSession = workoutSession
//        } catch {
//            throw error
//        }
//    }
//
//    func stopWorkout() {
//        guard let currentWorkoutSession = currentWorkoutSession else { return }
//        healthStore.end(currentWorkoutSession)
//        self.currentWorkoutSession = nil
//    }
//
//    func streamingQuery(withQuantityType type: HKQuantityType, startDate: Date, samplesHandler: @escaping ([HKQuantitySample]) -> Void) -> HKAnchoredObjectQuery {
//
//        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil)
//        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
//        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
//
//        let queryUpdateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { _, samples, _, _, error in
//
//            if let error = error {
//                print("Unexpected \(type) query error: \(error)")
//            }
//
//            if let samples = samples as? [HKQuantitySample], samples.count > 0 {
//                DispatchQueue.main.async {
//                    samplesHandler(samples)
//                }
//            }
//        }
//
//        let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit), resultsHandler: queryUpdateHandler)
//        query.updateHandler = queryUpdateHandler
//
//        return query
//    }
//
//}
