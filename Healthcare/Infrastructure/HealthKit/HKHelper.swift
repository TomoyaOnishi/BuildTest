//
//  HKHelper.swift
//  Healthcare
//
//  Created by T T on 2021/06/17.
//

import Foundation
import HealthKit
import Combine

struct HKHelper {

    let healthStore = HKHealthStore()
    let type: HKTypes

    init(type: HKTypes ) {
        self.type = type
    }

    /**
     *　直近 min 分の最新データを返すなければnil
     */
    func getMostRecent(min: Int) -> Future<Double?, Never> {
        return Future { promise in

            let now = Date()
            let startDate = Date().add(minute: -min)

            var interval = DateComponents()
            interval.minute = min

            let anchorDate = startDate
            let query = HKStatisticsCollectionQuery(quantityType: type.quantityType,
                                                    quantitySamplePredicate: nil,
                                                    options: [.mostRecent],
                                                    anchorDate: anchorDate,
                                                    intervalComponents: interval)

            query.initialResultsHandler = { _, results, error in
                guard let results = results else {
                    promise(.success(nil))
                    return
                }

                results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.mostRecentQuantity() {
                        let val = sum.doubleValue(for: type.hkUnit )
                        promise(.success(val))
                    } else {
                        promise(.success(nil))
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    func save(value: Double, start: Date, end: Date) -> Future<Void, Error> {
        return Future { promise in
            
            let quantity = HKQuantity(unit: type.hkUnit, doubleValue: value)
            let sampleData = HKQuantitySample(type: type.quantityType, quantity: quantity, start: start, end: end)

            healthStore.save(sampleData) { success, error in
                if success {
                    promise(.success(Void()))
                } else {
                    promise(.failure(HKError.fail))
                }
            }
        }
    }

    func getSampleData(start: Date, end: Date = Date()) -> Future<[HKQuantitySample], Never> {
        return Future { promise in

            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

            let query = HKSampleQuery(sampleType: type.quantityType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { (query, result, error) in
                let result = result as? [HKQuantitySample] ?? []

                if error != nil {
                    promise(.success([]))
                } else {
                    promise(.success(result))
                }
            }
            healthStore.execute(query)
        }
    }

    static func delete( objects: [HKObject]) -> Future<Void, Error> {

        return Future { promise in
            let store = HKHealthStore()
            store.delete(objects) { _, e in
                if e != nil {
                    promise(.success(Void()))
                } else {
                    promise(.failure(HKError.fail))
                }
            }
        }
    }

}

enum HKError: Error {
    case fail
}
