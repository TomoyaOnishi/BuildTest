//
//  DailyModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/18.
//

import Foundation

struct DailyModel: Identifiable {

    // yyyy/MM/dd
    let id: String

    let title: String

    let records: [BloodPressureRecordModel]

    let weightRecordModel: BodyMassRecordModel?

}

extension DailyModel {

    var lastDate: Date? {
        let last = self.records.max { a, b in
            return a.start < b.start
        }
        return last?.start
    }

    var date: Date {
        Date.dateFromString(string: id, format: "yyyy/MM/dd")
    }
}
