//
//  IHealthDataRepository.swift
//  Healthcare
//
//  Created by T T on 2021/06/17.
//

import Foundation
import Combine

protocol IHealthDataRepository {
    func getLastBodyMass(min: Int ) -> Future<Double?, Never>
    func getLastBloodPressureSystolic(min: Int ) -> Future<Double?, Never>
    func getLastBloodPressureDiastolic(min: Int ) -> Future<Double?, Never>

    func save( type: HKTypes, value: Double, start: Date, end: Date) -> Future<Void, Error>

}
