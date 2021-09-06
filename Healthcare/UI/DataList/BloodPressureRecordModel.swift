//
//  BloodPressureRecordModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/20.
//

import Foundation
import HealthKit

struct BloodPressureRecordModel: Identifiable {

    var id = UUID()
    /**
     * 最高血圧 (bloodPressureSystolic)
     */
    let bps: Double
    let _bps: HKQuantitySample?

    /**
     * 最低血圧 (bloodPressureDiastolic)
     */
    let bpd: Double
    let _bpd: HKQuantitySample?

    /**
     * 心拍
     */
    let heartRate: Double
    let _heartRate: HKQuantitySample?

    /**
     * 測定日時
     */
    let start: Date

    let end: Date

}

extension BloodPressureRecordModel {
    var bps_bpd: String {
        return "\(Int(bps)) / \(Int(bpd))"
    }

    var hhmm: String {
        self.start.stringFromDate(format: "HH:mm")
    }

    var hKQuantitySamples: [HKQuantitySample] {
        var samples: [HKQuantitySample] = []
        if let _bps = _bps { samples.append(_bps) }
        if let _bpd = _bpd { samples.append(_bpd) }
        if let _heartRate = _heartRate { samples.append(_heartRate) }
        return samples
    }
}
