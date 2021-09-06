//
//  DataListViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/18.
//

import Foundation
import Combine
import HealthKit

final class DataListViewModel: ViewModelObject {

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    final class Input: InputObject {
        let onAppear = PassthroughSubject<Void, Never>()
        let next = PassthroughSubject<Void, Never>()
        let get = PassthroughSubject<Void, Never>()
    }

    final class Output: OutputObject {
        @Published var dailys: [DailyModel] = []
        @Published var records: [BloodPressureRecordModel] = []
    }

    final class Binding: BindingObject {
        @Published var bloodH: String = ""

        @Published var newBloodPressure: Date?
        @Published var newBodyMass: Date?

        @Published var selectedBloodPressure: BloodPressureRecordModel?
        @Published var selectedBodyMass: BodyMassRecordModel?
    }

    private var cancellables = Set<AnyCancellable>()

    let healthDataRepository: IHealthDataRepository

    init(healthDataRepository: IHealthDataRepository = HealthDataRepositoryImpl()) {

        self.healthDataRepository = healthDataRepository
        self.input = Input()
        self.output = Output()
        self.binding = Binding()

        self.bindInputs()
        self.bindOutputs()
        self.request()
    }

    private func bindInputs() {
        self.input.onAppear.sink { [weak self] in
            guard let self = self else { return }
            self.getData(start: Date().add(days: -14))
        }.store(in: &cancellables)

        self.input.get.sink { [weak self] in
            guard let self = self else { return }
            self.getData(start: Date().add(days: -14))
        }.store(in: &cancellables)
    }
    private func bindOutputs() {
    }
    private func request() {
    }

    deinit {

    }
}

extension DataListViewModel {


    private func getData(start: Date){

        let heartRate = HKHelper(type: .heartRate).getSampleData(start: start )
        let bodyMass = HKHelper(type: .bodyMass).getSampleData(start: start )
        let bps = HKHelper(type: .bloodPressureSystolic).getSampleData(start: start )
        let bpd = HKHelper(type: .bloodPressureDiastolic).getSampleData(start: start )
        let bp = bps.zip(bpd )

        heartRate.zip(bodyMass, bp).sink { (heartRate, bodyMass, bp) in

            // 心拍 血圧はセット heartRateのタイムスタンプを基準にまとめる
            let bloodPressureList: [ BloodPressureRecordModel] = heartRate.compactMap({ heartRateData in
                let startDate = heartRateData.startDate
                guard let bps = bp.0.filter({$0.startDate == startDate }).first else { return nil}
                guard let bpd = bp.1.filter({$0.startDate == startDate }).first else { return nil}

                let bpsVal = bps.quantity.doubleValue(for: HKTypes.bloodPressureSystolic.hkUnit)
                let bpdVal = bpd.quantity.doubleValue(for: HKTypes.bloodPressureDiastolic.hkUnit)
                let heartRateVal = heartRateData.quantity.doubleValue(for: HKTypes.heartRate.hkUnit)

                let bpr = BloodPressureRecordModel(bps: bpsVal, _bps: bps, bpd: bpdVal, _bpd: bpd, heartRate: heartRateVal, _heartRate: heartRateData, start: startDate, end: startDate)

                return bpr
            })

            // 体重
            let bodyMassList: [ BodyMassRecordModel ] = bodyMass.compactMap { bodyMassData in
                let startDate = bodyMassData.startDate
                let bodyMassVal = bodyMassData.quantity.doubleValue(for: HKTypes.bodyMass.hkUnit)
                let bmr = BodyMassRecordModel(bodyMass: bodyMassVal, _bodyMass: bodyMassData, start: startDate, end: startDate)
                return bmr
            }

            // スタートから今日までの DailyModelを作成する
            var dateList: [Date] = [start]
            while !Calendar.current.isDateInToday(dateList.last!) {
                dateList.append(dateList.last!.add(days: 1))
            }

            // 日単位にまとめる
            var dailys: [DailyModel] = dateList.map { date in
                let key = date.stringFromDate(format: "yyyy/MM/dd")
                let title = date.stringFromDate(format: "M/d(EEE)")


                let bloodPressure = bloodPressureList.filter { bloodPressureRecordModel in
                    bloodPressureRecordModel.start.stringFromDate(format: "yyyy/MM/dd") == key
                }

                let bodyMass = bodyMassList.filter { bodyMass in
                    bodyMass.start.stringFromDate(format: "yyyy/MM/dd") == key
                }.last

                return DailyModel(id: key, title: title, records: bloodPressure, weightRecordModel: bodyMass)
            }

            dailys.sort { a, b in
                a.id > b.id
            }

            DispatchQueue.main.async {
                self.output.dailys = dailys
            }
        }.store(in: &cancellables)

    }
}
