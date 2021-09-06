//
//  WeightInputViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/08/29.
//

import Foundation
import Combine
import HealthKit

final class WeightInputViewModel: ViewModelObject {

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    final class Input: InputObject {
        let done = PassthroughSubject<Void, Never>()
        let delete = PassthroughSubject<BodyMassRecordModel, Never>()

    }

    final class Output: OutputObject {
        var initialRecord: BodyMassRecordModel?
        let dismiss = PassthroughSubject<Void, Never>()
    }

    final class Binding: BindingObject {
        init(date: Date?, bodyMass: BodyMassRecordModel? ) {
            self.bodyMass = bodyMass?.bodyMass.toInt().description ?? ""
            self.selectionDate = (bodyMass?.start ?? date) ?? Date()
        }

        @Published var bodyMass: String
        @Published var selectionDate: Date
        @Published var saveButtonisDisabled: Bool = true

    }

    private var cancellables = Set<AnyCancellable>()

    let healthDataRepository: IHealthDataRepository

    init( date: Date?, bodyMass: BodyMassRecordModel?,
          healthDataRepository: IHealthDataRepository = HealthDataRepositoryImpl()) {

        self.healthDataRepository = healthDataRepository
        self.input = Input()
        self.output = Output()
        self.binding = Binding(date: date, bodyMass: bodyMass)
        self.output.initialRecord = bodyMass

        self.bindInputs()
        self.bindOutputs()

    }

    private func bindInputs() {

        self.input.done.sink { [weak self] in
            guard let self = self else { return }
            guard let bodyMass = Double( self.binding.bodyMass) else { return }

            if self.output.initialRecord == nil {
                let newRecord = BodyMassRecordModel(bodyMass: bodyMass, _bodyMass: nil, start: self.binding.selectionDate, end: self.binding.selectionDate.add(minute: 1))

                self.save(record: newRecord, completion: { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.output.dismiss.send()
                    }
                })

            } else {
                guard let old = self.output.initialRecord else { return }
                let new = BodyMassRecordModel(bodyMass: bodyMass, _bodyMass: nil, start: self.binding.selectionDate, end: self.binding.selectionDate.add(minute: 1))

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
        self.binding.$bodyMass
            .map { Double( $0) == nil }
            .assign(to: &self.binding.$saveButtonisDisabled)
    }

    deinit {

    }
}

extension WeightInputViewModel {

    private func delete(record: BodyMassRecordModel, completion: @escaping () ->Void) {

        HKHelper.delete(objects: record.hKQuantitySamples).sink { err in
            completion()

        } receiveValue: { _ in

        }.store(in: &self.cancellables)

    }

    private func save(record: BodyMassRecordModel, completion: @escaping () ->Void) {

        let bodyMassFuture = HKHelper(type: .bodyMass).save(value: record.bodyMass, start: record.start, end: record.end)

        bodyMassFuture.sink { comp in
            completion()
        } receiveValue: { _ in

        }.store(in: &cancellables)

    }

    private func update(old: BodyMassRecordModel, new: BodyMassRecordModel) {

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
