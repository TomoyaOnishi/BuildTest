//
//  HKTypes.swift
//  Healthcare
//
//  Created by T T on 2021/06/16.
//

import Foundation
import HealthKit

enum HKTypes {

    case bodyMass
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case heartRate

    var quantityType: HKQuantityType {

        switch self {
        case .bodyMass:
            return HKSampleType.quantityType(forIdentifier: .bodyMass)!
        case .bloodPressureSystolic:
            return HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!
        case .bloodPressureDiastolic:
            return HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        case .heartRate:
            return HKSampleType.quantityType(forIdentifier: .heartRate)!

        }
    }
    var hkUnit: HKUnit {
        switch self {
        case .bodyMass:
            return HKUnit.gramUnit(with: .kilo)
        case .bloodPressureSystolic:
            return HKUnit.millimeterOfMercury()
        case .bloodPressureDiastolic:
            return HKUnit.millimeterOfMercury()
        case .heartRate:
            return HKUnit.count().unitDivided(by: HKUnit.minute())
        }
    }
}
