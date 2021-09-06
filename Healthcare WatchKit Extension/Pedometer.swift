//
//  Pedometer.swift
//  HealthcareWatchKitApp Extension
//
//  Created by Shin on 2021/06/15.
//

import SwiftUI
import CoreMotion

class Pedometer: ObservableObject {
    
    @Published var isStarted = false
    @Published var isWalking = false
    @Published var count: Int = 0
    
    let pedometer = CMPedometer()

    func start() {
        guard !isStarted else {
            return
        }

        isStarted = true
        if(CMPedometer.isStepCountingAvailable()){
            pedometer.startEventUpdates { (event, error) in
                guard error == nil else {
                    print("error: \(String(describing: error))")
                    return
                }
                
                DispatchQueue.main.async {
                    if event!.type == CMPedometerEventType.pause {
                        self.isWalking = false
                    } else {
                        self.isWalking = true
                    }
                }
            }
            
            pedometer.startUpdates(from: Date()) { (data, error) in
                guard error == nil else {
                    print("error \(String(describing: error))")
                    return
                }
                
                DispatchQueue.main.async {
                    guard let data = data,
                          let steps = data.numberOfSteps as? Int else { return }
                    self.count = steps
                    
//                    WatchConnectivityManager.shared.send([
//                        .pedometerIntergerValue : steps,
//                        .pedometerRecordDate : data.startDate,
//                        ])
                }
            }
        }
        
    }
    
    func stop() {
        guard isStarted else {
            return
        }
        
        isStarted = false
        
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    
}
