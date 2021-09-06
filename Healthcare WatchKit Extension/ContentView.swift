//
//  ContentView.swift
//  HealthcareWatchKitApp Extension
//
//  Created by Shin on 2021/05/31.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]

    var body: some View {
        TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date())) { context in
            VStack {
                Spacer()
                    .frame(height: 9)
                ElapsedTimeView(elapsedTime: (30 * 60 - Double(workoutManager.builder?.elapsedTime ?? 0)))
                    .foregroundStyle(.white)
                Spacer()
                HStack {
                    Spacer()
                    Image("Heart")
                        .resizable()
                        .frame(width: 18, height: 16)
                    Spacer()
                        .frame(width: 7)
                    Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                        .font(.system(size: 26))
                    Spacer()
                }
                Spacer()
                Button {
                    workoutManager.togglePause()
                } label: {
                    Text(workoutManager.running ? "一時停止" : "再開")
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                .frame(width: 144, height: 32)
                .background(Color.blue)
                .cornerRadius(14)
                Spacer()
                    .frame(height: 9)
            }
        }
        .onAppear {
            workoutManager.requestAuthorization()
            workoutManager.startWorkout(workoutType: .running)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WorkoutManager())
    }
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .walking:
            return "Walk"
        default:
            return ""
        }
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
    }
}

//import SwiftUI
//import HealthKit
//
//struct ContentView: View {
//
//    private var defaultWorkoutConfiguration: HKWorkoutConfiguration {
//
//        let configuration = HKWorkoutConfiguration()
//        configuration.activityType = .walking
//        configuration.locationType = .indoor
//
//        return configuration
//    }
//
//    @EnvironmentObject var workoutManager: WorkoutManager
//    @State private var currentQuery: HKAnchoredObjectQuery?
//    @State private var messageHandler: WatchConnectivityManager.MessageHandler?
//
//    var body: some View {
//        VStack {
//            Spacer()
//                .frame(height: 28)
//            CountDownTimerTextView()
//            Spacer()
//                .frame(height: 0)
//            PedometerView()
//            HStack {
//                Spacer()
//                Image("Heart")
//                    .frame(width: 18, height: 16)
//                Spacer()
//                    .frame(width: 6)
//                Text("\(workoutManager.heartRate)")
//                    .font(.system(size: 24))
//                Spacer()
//            }
//            Button(action: {
//                if workoutManager.running {
//                    stopWorkout()
//                } else {
//                    startWorkout()
//                }
//            }){
//                Text("一時停止")
//            }
//            .frame(width: 132, height: 28)
//            .background(Color.blue)
//            .cornerRadius(14)
//            Spacer()
//                .frame(height: 16)
//        }.onAppear {
//            messageHandler = WatchConnectivityManager.MessageHandler { message in
//                if message[.workoutStop] != nil {
//                    stopWorkout()
//                }
//            }
//            WatchConnectivityManager.shared.addMessageHandler(messageHandler!)
//        }.onDisappear {
//            messageHandler?.invalidate()
//        }
//    }
//
//    func startWorkout(with configuration: HKWorkoutConfiguration? = nil) {
//
//        if workoutManager.running {
//            workoutManager.resetWorkout()
//        }
//        if currentQuery != nil {
//            stopHeartRateQuery()
//        }
//
//        do {
//            workoutManager.startWorkout(workoutType: .running)
//
////            startHeartRateQuery()
//
//            if WKExtension.shared().applicationState == .active {
//                WKInterfaceDevice.current().play(.start)
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    WKInterfaceDevice.current().play(.start)
//                }
//            }
//        } catch {
//            let errorData = NSKeyedArchiver.archivedData(withRootObject: error)
////            WatchConnectivityManager.shared.send([.workoutError : errorData])
//        }
//    }
//
//    func stopWorkout() {
//        WKInterfaceDevice.current().play(.stop)
////        WatchConnectivityManager.shared.send([.workoutStop : true])
//
//        workoutManager.resetWorkout()
//    }
//
////    private func startHeartRateQuery() {
////
////        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
////
////        let predicate = HKQuery.predicateForSamples(withStart: Date() - 15 * 60, end: Date(), options: [])
////        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
////
////        workoutManager.healthStore.execute(HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 10, sortDescriptors: [sortDescriptor]) { _, samples, error in
////
////            if let samples = samples as? [HKQuantitySample] {
////                self.handle(newHeartRateSamples: Array(samples.reversed()))
////            }
////        })
////
////        let query = workoutManager.streamingQuery(withQuantityType: heartRateType, startDate: Date()) { samples in
////            self.handle(newHeartRateSamples: samples)
////        }
////        currentQuery = query
////        workoutManager.healthStore.execute(query)
////    }
//
//    private func stopHeartRateQuery() {
//        guard let query = currentQuery else { return }
//        workoutManager.healthStore.stop(query)
//        currentQuery = nil
//    }
//
////    private func handle(newHeartRateSamples samples: [HKQuantitySample]) {
////
////        for (index, sample) in samples.enumerated() {
////            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
////
////            let doubleValue = sample.quantity.doubleValue(for: heartRateUnit)
////            let integerValue = Int(round(doubleValue))
////            let date = sample.startDate
////            let dateString = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
////
////            print(doubleValue, dateString)
////
////            heartRate = integerValue
////            WatchConnectivityManager.shared.send([
////                .heartRateIntergerValue : integerValue,
////                .heartRateRecordDate : date,
////                ])
////        }
////    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
