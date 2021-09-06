//
//  DailyInputViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/20.
//

import Foundation
import Combine
import HealthKit

final class DailyInputViewModel: ViewModelObject {

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    final class Input: InputObject {
        let done = PassthroughSubject<Void, Never>()
        let delete = PassthroughSubject<BloodPressureRecordModel, Never>()
    }

    final class Output: OutputObject {
        var initialRecord: BloodPressureRecordModel?
        let dismiss = PassthroughSubject<Void, Never>()
    }

    final class Binding: BindingObject {
        init(date: Date?, record: BloodPressureRecordModel? ) {
            self.bps = record?.bps.toInt().description ?? ""
            self.bpd = record?.bpd.toInt().description ?? ""
            self.heartRate = record?.heartRate.toInt().description ?? ""
            self.selectionDate = (record?.start ?? date) ?? Date()
        }

        @Published var bps: String
        @Published var bpd: String
        @Published var heartRate: String
        @Published var selectionDate: Date
        @Published var saveButtonisDisabled: Bool = true

    }

    private var cancellables = Set<AnyCancellable>()

    let healthDataRepository: IHealthDataRepository

    init( date: Date?, record: BloodPressureRecordModel?,
          healthDataRepository: IHealthDataRepository = HealthDataRepositoryImpl()) {

        self.healthDataRepository = healthDataRepository
        self.input = Input()
        self.output = Output()
        self.binding = Binding(date: date, record: record)
        self.output.initialRecord = record
        self.bindInputs()
        self.bindOutputs()

    }

    private func bindInputs() {

        self.input.done.sink { [weak self] in
            guard let self = self else { return }
            guard let bps = Double( self.binding.bps) else { return }
            guard let bpd = Double( self.binding.bpd) else { return }
            guard let heartRate = Double( self.binding.heartRate) else { return }

            if self.output.initialRecord == nil {
                // 新規
                let newRecord = BloodPressureRecordModel(bps: bps, _bps: nil, bpd: bpd, _bpd: nil, heartRate: heartRate, _heartRate: nil, start: self.binding.selectionDate, end: self.binding.selectionDate.add(minute: 1))

                self.save(record: newRecord, completion: { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.output.dismiss.send()
                    }
                })

            } else {
                // 更新
                guard let old = self.output.initialRecord else { return }
                let new = BloodPressureRecordModel(bps: bps, _bps: nil, bpd: bpd, _bpd: nil, heartRate: heartRate, _heartRate: nil, start: self.binding.selectionDate, end: self.binding.selectionDate.add(minute: 1))

                self.update(old: old, new: new)

            }

        }.store(in: &cancellables)

        self.input.delete.sink { [weak self] record in
            guard let self = self else { return }

            self.delete(record: record) {
                DispatchQueue.main.async {
                    self.output.dismiss.send()
                }
            }

        }.store(in: &cancellables)

    }
    private func bindOutputs() {

        self.binding.$bps
            .combineLatest(self.binding.$bpd, self.binding.$heartRate)
            .map {
                Double( $0.0) == nil ||
                Double( $0.1) == nil ||
                Double( $0.2) == nil
            }
            .assign(to: &self.binding.$saveButtonisDisabled)
    }

    deinit {

    }
}

extension DailyInputViewModel {

    private func delete(record: BloodPressureRecordModel, completion: @escaping () ->Void) {

        HKHelper.delete(objects: record.hKQuantitySamples).sink { err in
            completion()

        } receiveValue: { _ in

        }.store(in: &self.cancellables)

    }

    private func save(record: BloodPressureRecordModel, completion: @escaping () ->Void) {

        let heartRateFuture = HKHelper(type: .heartRate).save(value: record.heartRate, start: record.start, end: record.end)
        let bpsFuture = HKHelper(type: .bloodPressureSystolic).save(value: record.bps, start: record.start, end: record.end)
        let bpdFuture = HKHelper(type: .bloodPressureDiastolic).save(value: record.bpd, start: record.start, end: record.end)
        let bpFuture = bpsFuture.zip(bpdFuture )

        heartRateFuture.zip( bpFuture)
            .sink { comp in
                print(comp)
                //                completion()
                completion()
            } receiveValue: { (a,b) in

            }.store(in: &cancellables)
        
    }

    private func update(old: BloodPressureRecordModel, new: BloodPressureRecordModel) {

        delete(record: old) { [weak self] in
            guard let self = self else { return }
            self.save(record: new) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.output.dismiss.send()
                }
            }
        }

    }
}

