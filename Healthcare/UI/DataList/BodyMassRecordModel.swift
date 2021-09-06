//
//  WeightRecordModel.swift
//  Healthcare
//
//  Created by T T on 2021/08/30.
//

import Foundation
import HealthKit

struct BodyMassRecordModel: Identifiable {

    var id = UUID()

    /**
     * 体重
     */
    let bodyMass: Double
    let _bodyMass: HKQuantitySample?

    /**
     * 測定日時
     */
    let start: Date

    let end: Date
}

extension BodyMassRecordModel {

    var hhmm: String {
        self.start.stringFromDate(format: "HH:mm")
    }

    var hKQuantitySamples: [HKQuantitySample] {
        var samples: [HKQuantitySample] = []
        if let _bodyMass = _bodyMass { samples.append(_bodyMass) }
        return samples
    }
}
