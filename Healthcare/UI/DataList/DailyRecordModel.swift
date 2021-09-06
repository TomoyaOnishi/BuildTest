//
//  DailyRecordModel.swift
//  Healthcare
//
//  Created by T T on 2021/08/30.
//

import Foundation
import HealthKit

struct DailyRecordModel: Identifiable {

    let id: String // 日付

    /**
     * 血圧/脈拍
     */
    let bp: [BloodPressureRecordModel]

    /**
     * 体重
     */
    let weight: BodyMassRecordModel?
}
