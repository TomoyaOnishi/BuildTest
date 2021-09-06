//
//  HealthDataRepositoryImpl.swift
//  Healthcare
//
//  Created by T T on 2021/06/17.
//

import Foundation
import Combine
import HealthKit

struct HealthDataRepositoryImpl: IHealthDataRepository {

    func getLastBodyMass(min: Int) -> Future<Double?, Never> {
        return HKHelper(type: .bodyMass).getMostRecent(min: min)
    }

    func getLastBloodPressureSystolic(min: Int) -> Future<Double?, Never> {
        return HKHelper(type: .bloodPressureSystolic).getMostRecent(min: min)
    }

    func getLastBloodPressureDiastolic(min: Int) -> Future<Double?, Never> {
        return HKHelper(type: .bloodPressureDiastolic).getMostRecent(min: min)
    }

    func save( type: HKTypes, value: Double, start: Date, end: Date) -> Future<Void, Error>  {
        return HKHelper(type: type).save(value: value, start: start, end: end)
    }
}
